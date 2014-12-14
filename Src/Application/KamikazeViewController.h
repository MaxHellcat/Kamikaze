//
//  KamikazeViewController.h
//  Kamikaze
//
//  Created by Max Reshetey on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@interface KamikazeViewController : UIViewController<UIAccelerometerDelegate>
{
@private
    BOOL animating;
    CADisplayLink * displayLink;
	NSTimer * eventLink;
	NSTimer * eventOneHertz;

    // This should not ever be needed
	//GLbyte _deviceName; // The device we are runnning on
}

//@property (nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic, assign) CADisplayLink * displayLink;
@property (nonatomic, assign) NSTimer * eventLink;
@property (nonatomic, assign) NSTimer * eventOneHertz;

//@property (nonatomic, retain) id displayLink;

- (void)startAnimation;
- (void)stopAnimation;
- (id)init;

@end
