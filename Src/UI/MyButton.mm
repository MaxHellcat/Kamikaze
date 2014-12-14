//
//  MyButton.mm
//  Kamikaze
//
//  Created by Max Reshetey on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyWidget.h"

#import "StateController.h"


@implementation _Button
@synthesize action;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (action != 0)
	{
		// A bit of magic here
		GarageRenderer * p = (GarageRenderer *)StateController::get()->activeRenderer();
		(p->*action)([self tag]);
	}
	[super touchesEnded:touches withEvent:event]; // Important, else won't change state images
}

- (void)dealloc
{
    [super dealloc];
}
@end

MyButton & MyButton::init(const char * imageNormal, Pointer p)
{
	NSString * nsImageNormal = [NSString stringWithCString:imageNormal encoding:NSUTF8StringEncoding];
//	NSString * nsImageTouched = [NSString stringWithCString:imageTouched encoding:NSUTF8StringEncoding];
//	NSString * nsImageDisabled = [NSString stringWithCString:imageDisabled encoding:NSUTF8StringEncoding];

	// Set correct button bounds based on image dimensions
	UIImage * image = [UIImage imageNamed:nsImageNormal];

	_wrapped = [[_Button alloc] initWithFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)]; // Must be overrides by the caller

	[_wrapped setImage:[UIImage imageNamed:nsImageNormal] forState:UIControlStateNormal];

	[_wrapped setAction:p];

//	[_button release];

//	[_button setCenter:CGPointMake(300.0f, 300.0f)];

//	[_button setUserInteractionEnabled:YES];
//	_button.adjustsImageWhenDisabled = YES;
//	_button.adjustsImageWhenHighlighted = YES;

//	[_wrapped setShowsTouchWhenHighlighted:YES]; // Nice glow effect when touched

//	[_button setTitle:@"Nice button" forState:UIControlStateHighlighted];

//	[StateController::get()->_view addSubview:_button];

/*
	[_imageView setUserInteractionEnabled:YES]; // It is off by default
*/

	return * this;
}

MyButton & MyButton::attach(UIView * viewToAttach)
{
	MyWidget<_Button>::attach(viewToAttach);
	
	return * this;
}
