//
//  BodySimple.cpp
//  Kamikaze
//
//  Created by Max Reshetey on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "BodySimple.h"

Widget::Widget(float halfWidth, float halfHeight, float posX, float posY, float posZ) :
BodySimple(halfWidth, halfHeight, posX, posY, posZ),
_posXp(0.0f), _posYp(0.0f), _halfWidthP(0.0f), _halfHeightP(0.0f),
_hasKids(false), _animateStep(0.0f), _animateLimit(2.0f),
_touchHalfWidthP(0.0f), _touchHalfHeightP(0.0f),
_texForTouch(0), _texForUntouch(0)
{
	setPosX(posX); // Set initial position and calculate pixel coords
	setPosY(posY);

	setSize(halfWidth, halfHeight);

	resetAnimation(2.0f);
}

Widget::Widget() :
BodySimple(),
_posXp(0.0f), _posYp(0.0f), _halfWidthP(0.0f), _halfHeightP(0.0f),
_hasKids(false), _animateStep(0.0f), _animateLimit(2.0f),
_texForTouch(0), _texForUntouch(0)
{
	// Must set pos in pixel, even id scene pos are zero!
	setPosX(0.0f); // Set initial position and calculate pixel coords
	setPosY(0.0f);

	// Cannot set size here, hence you must call at least setSize() prior to work with object
	resetAnimation(2.0f);
}

Widget::~Widget()
{
	// TODO: Is it healthy?
	delete _texForTouch; _texForTouch = 0;
	delete _texForUntouch; _texForUntouch = 0;

	// Release all subwidgets
	for (std::vector<Widget *>::iterator it = _kids.begin(); it != _kids.end(); ++it)
	{
		delete *it; *it = 0;
	}
};

// Animation is done solely by GL translating, which results in different body
// position during animation
Widget & Widget::draw(bool addOwnPos, GLfloat adjX, GLfloat adjY, GLfloat adjZ)
{
	push();
	Body::draw(addOwnPos, adjX, adjY, adjZ); // Draw self
	pop();
	
	if (_hasKids) // Then all the kids
	{
		for (std::vector<Widget *>::iterator
			 it = _kids.begin(); it != _kids.end(); ++it)
		{
			(*it)->push().draw().pop();
		}
	}
	
	return * this;
}

void Widget::drawAnimated()
{
	push().place(false, 0.0f, sinf(_animateStep+=0.1f)*_animateLimit).draw().pop();
	if (_animateLimit > 0.01f)
		_animateLimit -= 0.02f;
}

Widget & Widget::setPosX(float posX)
{
	_posXp = (posX + kSceneWidth/2.0f) * Settings::get()->pixelFactor();
	BodySimple::setPosX(posX);
	return * this;
}

Widget & Widget::setPosY(float posY)
{
	_posYp = (kSceneHeight/2.0f - posY) * Settings::get()->pixelFactor();
	BodySimple::setPosY(posY);
	return * this;
}

Widget & Widget::setPos(float posX, float posY)
{
	this->setPosX(posX);
	this->setPosY(posY);
	return * this;
}

Widget & Widget::setSize(float halfWidth, float halfHeight)
{
	Body::setSize(halfWidth, halfHeight);

	_halfWidthP = _halfWidth * Settings::get()->pixelFactor();
	_halfHeightP = _halfHeight * Settings::get()->pixelFactor();
	_touchHalfWidthP = _halfWidthP;
	_touchHalfHeightP = _halfHeightP;

	return * this;
}

Widget * Widget::isTouched(float touchX, float touchY)
{
//	printf("Widget::isTouched, x: %f, y: %f\n", touchX, touchY);
//	printf("_posXp: %f, _posYp: %f\n", _posXp, _posYp);

	if (touchX > _posXp-_touchHalfWidthP && touchX < _posXp+_touchHalfWidthP &&
		touchY > _posYp-_touchHalfHeightP && touchY < _posYp+_touchHalfHeightP)
	{
		return this;
	}
	return 0;
}

Widget * Widget::isKidTouched(float touchX, float touchY)
{
	for (std::vector<Widget *>::iterator it = _kids.begin(); it != _kids.end(); ++it)
	{
		if ((*it)->isTouched(touchX, touchY))
		{
			(*it)->setTextureFast((*it)->_texForTouch); // Automatically change texture
			return (*it);
		}
	}
	return 0;
}

Widget * Widget::isKidUntouched(float touchX, float touchY)
{
	for (std::vector<Widget *>::iterator it = _kids.begin(); it != _kids.end(); ++it)
	{
		if ((*it)->isTouched(touchX, touchY))
		{
			(*it)->setTextureFast((*it)->_texForUntouch);
			return (*it);
		}
	}
	return 0;
}

Widget & Widget::addSubWidget(const char * tag, float halfWidth, float halfHeight, float localPosX, float localPosY, float posZ)
{
	Widget * widget = new Widget(halfWidth, halfHeight, localPosX+_posX, localPosY+_posY, posZ);
	widget->_tag = tag;

	_kids.push_back(widget);

	if (!_hasKids) _hasKids = true;

	return * widget;
}

Widget & Widget::addTexture(const char * texName, bool clampToEdge)
{
	 // Store reference as we'll need to switch fast
	_meshes[_meshes.size()-1].texUnits.push_back(*(_texForUntouch = new Texture(texName, clampToEdge)));
	return * this;
}

void Widget::setTextureFast(Texture * texture)
{
	_meshes[_meshes.size()-1].texUnits[0] = *texture;
}

void Widget::dumpKids()
{
	printf("====== Dumping kids ======\n");
	for (std::vector<Widget *>::iterator it = _kids.begin(); it != _kids.end(); ++it)
	{
		printf("Kid, tag: %s\n", (*it)->_tag.c_str());
	}
}
