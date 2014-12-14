//
//  BodySimple.h
//  Kamikaze
//
//  Created by Max Reshetey on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef BODY_SIMPLE_H
#define BODY_SIMPLE_H

#include "Body.h"

// Class representing a body, which is off any physical emulation. Should be used for simple
// objects, like buttons, etc.
// BodySimple knows about the texture it should use, so only call setTexture() if you really need to.
// BodySimple knows about the VBO data it should use, so don't provide any
class BodySimple : public Body
{
public:
	BodySimple(float halfWidth, float halfHeight, float posX=0.0f, float posY=0.0f, float posZ=0.0f) :
	Body(halfWidth, halfHeight, posZ), _posX(posX), _posY(posY), _angle(0.0f) {}

	virtual ~BodySimple() { /* nothing to release */ };

	// Special case for declaring objects.
	// If you use this, you must init Body size, position prior to use
	BodySimple() : Body(0.0f, 0.0f, 0.0f), _posX(0.0f), _posY(0.0f), _angle(0.0f) {};

	virtual const float posX() const { return _posX; }
	virtual BodySimple & setPosX(float posx) { _posX = posx; return * this; }
	virtual const float posY() const { return _posY; }
	virtual BodySimple & setPosY(float posy) { _posY = posy; return * this; }
	virtual const float angle() const { return _angle; }
	virtual void setAngle(float degrees) {_angle = degrees; }
	void adjAngle(float degrees) { _angle += degrees; }

	virtual BodySimple & ddraw(bool addOwnPos = true, bool drawJoint = false) { return * this; }

	BodySimple & adjPosX(float adjPosX) { _posX += adjPosX; return * this; }
	BodySimple & adjPosY(float adjPosY) { _posY += adjPosY; return * this; }

	virtual void shouldDie() {}
	
	virtual BodySimple & push() { MatrixManager::get()->pushMatrix(); return * this; }

protected: // Variables
	float _posX, _posY; // Body's current position
	float _angle;
};

// TODO: Add ability to internally support textures for two states: touched/untouched
// In addidition to SimpleBody, knows when it is touched
// Use for any touchable screen control, like buttons, joystick, etc
// TODO: Real sizes of textures don't always equal specified body sizes, this is
// rather unhandy as we always need to find out the real texture size first
class Widget : public BodySimple
{
public:
	Widget(float halfWidth, float halfHeight, float posX=0.0f, float posY=0.0f, float posZ=0.0f);
	virtual ~Widget();

	// Special case for declaring as objects
	Widget();

	Widget * isTouched(float touchX, float touchY);
	Widget * isKidTouched(float touchX, float touchY);
	Widget * isKidUntouched(float touchX, float touchY); // For changing texture only

	virtual Widget & setPosX(float posX);
	virtual Widget & setPosY(float posY);
	virtual Widget & setPos(float posX, float posY);
	virtual Widget & setSize(float halfWidth, float halfHeight = 0.0f);
	Widget & adjustTouchArea(float newHalfWidth, float newHalfHeight)
	{
		_touchHalfWidthP = newHalfWidth*Settings::get()->pixelFactor();
		_touchHalfHeightP = newHalfHeight*Settings::get()->pixelFactor();
		return * this;
	}

	// Local touch coordinates in pixels, with the origin in the body center
	float getLocalTouchY(float touchY) { return _posYp - touchY; }
	float getLocalTouchX(float touchX) { return touchX - _posXp; }

	// World touch coordinates in pixels, with the origin in the body center
	float getWorldTouchY(float touchY) { return Settings::get()->screenHeight()/2.0f - touchY; }
	float getWorldTouchX(float touchX) { return touchX - Settings::get()->screenWidth()/2.0f; }

	Widget & addSubWidget(const char * tag, float halfWidth, float halfHeight, float localPosX=0.0f, float localPosY=0.0f, float posZ=0.0f);

	Widget & setTag(const char * tag) { _tag = tag; return * this; }
	const std::string tag() const { return _tag; }

	virtual Widget & draw(bool addOwnPos = true, float adjX=0.0f, float adjY=0.0f, float adjZ=0.0f);
	void drawAnimated();

	Widget & setTextureForTouched(const char * texName) { _texForTouch = new Texture(texName, false); return * this; }

	Widget * lastKid() { return _kids[_kids.size()-1]; }

	void dumpKids(); // For debug
	
	virtual Widget & addTexture(const char * texName, bool clampToEdge=false);

	// TODO: Maybe move into Body root, if useful for other
	void setTextureFast(Texture * texture);

	void resetAnimation(float newLimit = 2.0f) { _animateLimit = newLimit; }

private: // Variables
	// For quick touch processing, duplicate Body:: ones, but in pixels
	float _posXp, _posYp, _halfWidthP, _halfHeightP;
	bool _hasKids; // For quick checking when touch processing
	float _animateStep, _animateLimit;
	float _touchHalfWidthP, _touchHalfHeightP; // Adjustable touch area (by default equals halfWidthP)

	// Note: I think its ok to use strings here
	std::string _tag; // For identifying the exact kid (e.g. when touched)

	std::vector<Widget *> _kids;

	// TODO: Store texture itself, for fast switching (e.g. button up/down)
	Texture * _texForTouch, * _texForUntouch;
};

#endif
