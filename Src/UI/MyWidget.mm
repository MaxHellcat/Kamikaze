//
//  Label.mm
//  Kamikaze
//
//  Created by Max Reshetey on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyWidget.h"

#include "Misc.h"
#include "constants.h"

#include "StateController.h"


@implementation _ImageView
- (void)dealloc
{
    [super dealloc];
}
@end

template <class T>
MyWidget<T> & MyWidget<T>::attach(UIView * viewToAttach)
{
	if (viewToAttach == 0)
		[StateController::get()->_view addSubview:wrapped()]; // The _window retained here
	else
		[viewToAttach addSubview:wrapped()];

	[wrapped() release]; // so can release it

	return * this;
}

// Explicit instantiation for each kid, or won't link
MyImage & MyImage::attach(UIView * viewToAttach)
{
	MyWidget<_ImageView>::attach(viewToAttach);

	return * this;
}

MyImage & MyImage::init(const char * imageName, float posX, float posY, Pointer action)
{
	NSString * nsImageName = [NSString stringWithCString:imageName encoding:NSUTF8StringEncoding];

	_wrapped = [[_ImageView alloc] initWithImage:[UIImage imageNamed:nsImageName]];

	float posXp = (posX + kSceneWidth/2.0f) * Settings::get()->pixelFactor();
	float posYp = (kSceneHeight/2.0f - posY) * Settings::get()->pixelFactor();
	[_wrapped setCenter:CGPointMake(posXp, posYp)];

	[_wrapped setUserInteractionEnabled:YES]; // It is off by default

	return * this;
}

MoneyWidget & MoneyWidget::init(const char * imageName, float posX, float posY, Pointer action)
{
	MyImage::init(imageName, posX, posY, action);

	_val.init(0.0f, 0.0f, 24).attach(); // Will adjust in a moment
	_val.setPosInPixels([_wrapped center].x+90.0f, [_wrapped center].y);

	_token.init(0.0f, 0.0f, 16).attach();

	return * this;
}

MoneyWidget & MoneyWidget::setToken(const char * s)
{
	_token.setText(s);
	return * this;
}

MoneyWidget & MoneyWidget::setText(unsigned int val)
{
	_val.setText(val);
	CGSize offset = [[_val.wrapped() text] sizeWithFont:[UIFont fontWithName:@"Komika Axis" size:24]];
	_token.setPosInPixels([_wrapped center].x + 95.0f + offset.width, [_wrapped center].y+4.0f);
	return * this;
}

MoneyWidget & MoneyWidget::setText(const char * s)
{
	_val.setText(s);
	CGSize offset = [[_val.wrapped() text] sizeWithFont:[UIFont fontWithName:@"Komika Axis" size:24]];
	_token.setPosInPixels([_wrapped center].x + 95.0f + offset.width, [_wrapped center].y+4.0f);
	return * this;
}

StripWidget & StripWidget::addItem(const char * imageName, byte tag, Pointer action)
{
	MyButton but;

	but.init(imageName, action).setTag(tag).setPosInPixels(indexOffset, 90.0f);
	indexOffset += 150.0f;

	but.attach(_wrapped);

	return * this;
}

DetailsWidget & DetailsWidget::init(const char * imageName, float posX, float posY, Pointer p)
{
	MyImage::init(imageName, posX, posY, p);

	_pricePoints.init(0.0f, 0.0f, 24).attach(_wrapped);
	_pricePoints.setPosInPixels(_offsetX, _offsetY);
	_pointsToken.init(0.0f, 0.0f, 16).attach(_wrapped);

	_slash.init(0.0f, 0.0f, 24).attach(_wrapped);

	_priceMoney.init(0.0f, 0.0f, 24).attach(_wrapped); // Will adjust in a moment
	_moneyToken.init(0.0f, 0.0f, 16).attach(_wrapped);


	_name = [[_Label alloc] initWithFrame: CGRectMake(175.0f, 50.0f, 300.0f, 20.0f)];
	_name.font = [UIFont fontWithName:@"Komika Axis" size:20];
	_name.textColor = [UIColor whiteColor];
	_name.backgroundColor = [UIColor clearColor];
//	_name.backgroundColor = [UIColor redColor];
	[_wrapped addSubview:_name];
	[_name release];

	_desc = [[_Label alloc] initWithFrame: CGRectMake(175.0f, 75.0f, 300.0f, 90.0f)];
	_desc.font = [UIFont fontWithName:@"Komika Axis" size:14];
	_desc.textColor = [UIColor whiteColor];
	_desc.backgroundColor = [UIColor clearColor];
//	_desc.backgroundColor = [UIColor greenColor];
	[_desc setNumberOfLines:0]; // Endless line number
	[_desc setTextAlignment:UITextAlignmentLeft];
	[_wrapped addSubview:_desc];
	[_desc release];

	// TODO: Try this to adjust label text!
//	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

	_get.init("get_button.png", &GarageRenderer::touchItemGet).
	setPosInPixels([_wrapped center].x, [_wrapped center].y+110.0f).attach();

	_preview.init("preview_button.png", &GarageRenderer::touchItemPreview).
	setPosInPixels([_wrapped center].x+150.0f, [_wrapped center].y+110.0f).attach();

	return * this;
}

DetailsWidget & DetailsWidget::setVisible(bool isVisible)
{
	MyImage::setVisible(isVisible);
	_get.setVisible(isVisible); // Set separately, because not kids
	_preview.setVisible(isVisible);

	return * this;
}

DetailsWidget & DetailsWidget::setPrice(uint points, uint money)
{
	_pricePoints.setText(points);
	CGSize offset = [[_pricePoints.wrapped() text] sizeWithFont:[UIFont fontWithName:@"Komika Axis" size:24]];
	_pointsToken.setPosInPixels(_offsetX+offset.width, _offsetY+4.0f);
	_pointsToken.setText("pts");

	CGSize offsetToken = [[_pointsToken.wrapped() text] sizeWithFont:[UIFont fontWithName:@"Komika Axis" size:16]];
	_slash.setPosInPixels(_offsetX+offset.width+offsetToken.width+5.0f, _offsetY);
	_slash.setText("/");

	_priceMoney.setText(money);
	CGSize offsetSlash = [[_slash.wrapped() text] sizeWithFont:[UIFont fontWithName:@"Komika Axis" size:24]];
	_priceMoney.setPosInPixels(_offsetX+offset.width+offsetToken.width+offsetSlash.width+10.0f, _offsetY);

	CGSize offsetScore = [[_priceMoney.wrapped() text] sizeWithFont:[UIFont fontWithName:@"Komika Axis" size:24]];
	_moneyToken.setPosInPixels(_offsetX+offset.width+offsetToken.width+offsetSlash.width+offsetScore.width+10.0f, _offsetY+4.0f);
	_moneyToken.setText("$");

	return * this;
}

DetailsWidget & DetailsWidget::setName(const char * name)
{
	NSString * nsText = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	[_name setText:nsText];

	return * this;
}

DetailsWidget & DetailsWidget::setDesc(const char * desc)
{
	NSString * nsText = [NSString stringWithCString:desc encoding:NSUTF8StringEncoding];
	[_desc setText:nsText];

	return * this;
}

PopupWidget & PopupWidget::init(const char * imageName, Pointer action)
{
	MyImage::init(imageName, 0.0f, 0.0f, action);
	setPosInMeters(0.0f, 0.0f);

	_yes.init("yes_button.png", action).setTag(eActionYes).setPosInPixels(100.0f, 150.0f).attach(_wrapped);
	_no.init("no_button.png", action).setTag(eActionNo).setPosInPixels(300.0f, 150.0f).attach(_wrapped);

	_text.init(0.0f, 0.0f, 24).attach(_wrapped);

	[_text.wrapped() setNumberOfLines:0];
//	[_text.wrapped() setBackgroundColor:[UIColor greenColor]]; // Enable to test bounds
	[_text.wrapped() setBounds:CGRectMake(0.0f, 0.0f, 350.0f, 100.0f)];

	// Aim texfield right into the popup center (then shift up a bit above yes/ok buttons)
	_text.setPosInPixels([wrapped() bounds].size.width/2.0f, [wrapped() bounds].size.height/2.0f-20.0f);

//	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	

	return * this;
}

PopupWidget & PopupWidget::setText(const char * s)
{
	_text.setText(s);
	return * this;
}

void PopupWidget::destroy()
{
	this->removeKids();

	[_wrapped removeFromSuperview];
}