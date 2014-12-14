//
//  Label.mm
//  Kamikaze
//
//  Created by Max Reshetey on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "MyWidget.h"

#include "Misc.h"
#include "constants.h"

#include "StateController.h"


MyLabel & MyLabel::init(float posX, float posY, int fontSize)
{
	float posXp = (posX + kSceneWidth/2.0f) * Settings::get()->pixelFactor();
	float posYp = (kSceneHeight/2.0f - posY) * Settings::get()->pixelFactor();
	_wrapped = [[_Label alloc] initWithFrame: CGRectMake(posXp, posYp, 100.0f, 50.0f)];

	_wrapped.font = [UIFont fontWithName:@"Komika Axis" size:fontSize];
	_wrapped.textColor = [UIColor whiteColor];
	_wrapped.backgroundColor = [UIColor clearColor];

	return * this;
}

MyLabel & MyLabel::setText(const char * s)
{
	NSString * nsText = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
	[_wrapped setText:nsText];
	return * this;
}

MyLabel & MyLabel::setText(int num)
{
	char buf[10];
	sprintf(buf, "%i", num);
	setText(buf);
	return * this;
}

@implementation _Label
- (void)dealloc
{
    [super dealloc];
}
@end
