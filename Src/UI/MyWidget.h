//
//  Window.h
//  Kamikaze
//
//  Created by Max Reshetey on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef MYWIDGET_H
#define MYWIDGET_H

#import <Foundation/Foundation.h>

#include "constants.h"
#include "Misc.h"

class GarageRenderer;
typedef void (GarageRenderer::*Pointer)(byte); // Pointer to a touch handler, usually method of active renderer

@interface _ImageView : UIImageView {}
@end

@interface _Label : UILabel {}
@end

@interface _Button : UIButton
{
@public
	Pointer action;
}
@property (nonatomic, assign) Pointer action;
@end


// Essentially an interface
template <typename T>
class MyWidget
{
public:
	MyWidget() : _wrapped(0) {};
	virtual ~MyWidget() {};

	MyWidget & setTag(byte tag) { [wrapped() setTag: tag]; return * this; }

//	MyWidget & attach(UIView * viewToAttach = 0) { return * this; }
	virtual MyWidget & attach(UIView * viewToAttach = 0);

	const bool visible() const { return !(bool)[_wrapped isHidden]; }
	MyWidget & setVisible(bool isVisible) { [wrapped() setHidden: !(BOOL)isVisible]; return * this; }

	MyWidget & setPosInMeters(float posX, float posY)
	{
		float posXp = (posX + kSceneWidth/2.0f) * Settings::get()->pixelFactor();
		float posYp = (kSceneHeight/2.0f - posY) * Settings::get()->pixelFactor();
		[_wrapped setCenter:CGPointMake(posXp, posYp)];
		return * this;
	}
	MyWidget & setPosInPixels(float posX, float posY) { [_wrapped setCenter:CGPointMake(posX, posY)]; return * this; }

	virtual T * wrapped() { return _wrapped; }
	virtual const T * wrapped() const { return _wrapped; }

protected:
	T * _wrapped; // Underlying UI object
};

class MyButton : public MyWidget<_Button>
{
public:
	MyButton() {};
	virtual ~MyButton() {};

	virtual MyButton & attach(UIView * viewToAttach);

	MyButton & init(const char * imageNormal, Pointer p);
};

class MyLabel : public MyWidget<_Label>
{
public:
	MyLabel() {};
	virtual ~MyLabel() {};

	MyLabel & init(float posX, float posY, int size=20);

	MyLabel & setText(const char * s);
	MyLabel & setText(int num);

	MyLabel & setFontSize(int size) { _wrapped.font = [UIFont fontWithName:@"Komika Axis" size:size]; return * this; }

	MyLabel & setNumberOfLines(byte n) { [_wrapped setNumberOfLines:n]; return * this; }

	
};

class MyImage : public MyWidget<_ImageView>
{
public:
	MyImage() {};
	virtual ~MyImage() { /*removeKids();*/ };

	MyImage & init(const char * imageName, float posX, float posY, Pointer p);

	virtual MyImage & attach(UIView * viewToAttach = 0);

	MyImage & removeKids()
	{
		for (UIView * sv in [wrapped() subviews])
		{
			[sv removeFromSuperview];
		}
		return * this;
	}
};

class MoneyWidget : public MyImage
{
public:
	MoneyWidget() {};
	~MoneyWidget() {};

	MoneyWidget & init(const char * imageName, float posX, float posY, Pointer p);

	MoneyWidget & setText(const char * s);
	MoneyWidget & setText(unsigned int val);
	MoneyWidget & setToken(const char * s);

//private:
	MyLabel _val, _token;
};

// Class for Garage strip popup
class StripWidget : public MyImage
{
public:
	StripWidget() : indexOffset(100.0f) {}
	virtual ~StripWidget() {}

	StripWidget & addItem(const char * imageName, byte tag, Pointer action);
	virtual StripWidget & removeKids() { indexOffset = 100.0f; MyImage::removeKids(); return * this; }

private:
	float indexOffset; // For internal use, autoindent of item icons
};

class DetailsWidget : public MyImage
{
public:
	DetailsWidget() : _offsetX(230.0f), _offsetY(25.0f) {};
	~DetailsWidget() {}

	DetailsWidget & init(const char * imageName, float posX, float posY, Pointer p);
	DetailsWidget & setPrice(uint points, uint money);
	DetailsWidget & setName(const char * name);
	DetailsWidget & setDesc(const char * desc);

	virtual DetailsWidget & setVisible(bool isVisible);

private:
	MyLabel _pricePoints, _pointsToken, _slash, _priceMoney, _moneyToken;
	_Label * _name, * _desc;
	float _offsetX, _offsetY;

	MyButton _get, _preview; // Buttons below the widget (not its subviews!)
};

class PopupWidget : public MyImage
{
public:
	PopupWidget() {};
	virtual ~PopupWidget() {};

	PopupWidget & init(const char * imageName, Pointer action);
	PopupWidget & setText(const char * s);

	// Remove kids and detach itself fron the parent
	void destroy();

private:
	MyLabel _text;
	MyButton _yes, _no;
};


/*
class InsufficientPopup : public MyWidget
{
public:
	InsufficientPopup() {};
	~InsufficientPopup() {};
	
	virtual InsufficientPopup & init(const char * imageName, float posX, float posY);
};

class ConfirmPopup : public MyWidget
{
public:
	ConfirmPopup() {};
	~ConfirmPopup() {};

	virtual ConfirmPopup & init(const char * imageName, float posX, float posY);

	virtual ConfirmPopup & setVisible(bool isVisible)
	{
		printf("Setting exclusive!\n");
		[_window setExclusiveTouch:YES];
		MyWidget::setVisible(isVisible);
		return * this;
	}

};
*/
#endif
