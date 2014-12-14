//
//  KamikazeViewController.m
//  Kamikaze
//
//  Created by Max Reshetey on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "KamikazeViewController.h"
#import "EAGLView.h"
//#import "UIMyButton.h"

#include "StateController.h"
#include "PlayerCareer.h"

#import <sys/utsname.h> // For uname()

#include "constants.h"

#include "Misc.h"

//#import "Button.h"

@implementation KamikazeViewController

@synthesize displayLink, eventLink, eventOneHertz;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//	return YES; // Any orientation
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation); // Allow only landscape orientation
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight); // Allow only landscape orientation (button at right)
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"View rotated, changing dimensions, w: %d, h: %d\n", [(EAGLView *)[self view] layerWidth], [(EAGLView *)[self view] layerHeight]);

	// Update settings with changed screen sizes
	Settings::get()->setScreenSize([(EAGLView *)[self view] layerWidth], [(EAGLView *)[self view] layerHeight]);
}

- (id)init
{
	if ((self = [super init])) // Double parenthesies not by accident
	{
		// Now lets work out the device we are running on
		// Use strstr for 100% checking (as opposed to strcmp)
		struct utsname systemInfo;
		uname(&systemInfo);
#if 0
		_deviceName = iPad; // Default to original iPad
		if (strcmp("i386", systemInfo.machine) == 0)
			_deviceName = Simulator;
		// iPod
		else if (strcmp("iPod1,1", systemInfo.machine) == 0)
			_deviceName = iPodTouch; // Don't support, MBX chipset
		else if (strcmp("iPod2,1", systemInfo.machine) == 0)
			_deviceName = iPodTouch2; // Don't support, MBX chipset
		else if (strcmp("iPod3,1", systemInfo.machine) == 0)
			_deviceName = iPodTouch3;
		else if (strcmp("iPod4,1", systemInfo.machine) == 0)
			_deviceName = iPodTouch4;
		// iPhone
		else if (strcmp("iPhone1,1", systemInfo.machine) == 0)
			_deviceName = iPhone; // Don't support, MBX chipset
		else if (strcmp("iPhone1,2", systemInfo.machine) == 0)
			_deviceName = iPhone3G; // Don't support, MBX chipset
//		else if (strcmp("iPhone2,1", systemInfo.machine) == 0)
//			_deviceName = iPhone3GS;
		else if (strstr(systemInfo.machine, "iPhone2,"))
			_deviceName = iPhone3GS;
//		else if (strcmp("iPhone3,1", systemInfo.machine) == 0)
//			_deviceName = iPhone4; // GSM
//		else if (strcmp("iPhone3,3", systemInfo.machine) == 0)
//			_deviceName = iPhone4; // CDMA is iPhone3,3 - really?
		else if (strstr(systemInfo.machine, "iPhone3,"))
			_deviceName = iPhone4;
//		else if (strcmp("iPad1,1", systemInfo.machine) == 0)
//			_deviceName = iPad; // Also GSM/CDMA versions
		else if (strstr(systemInfo.machine, "iPad1,"))
			_deviceName = iPad;
//		else if (strcmp("iPad2,1", systemInfo.machine) == 0)
//			_deviceName = iPad2;  // Also GSM/CDMA versions
		else if (strstr(systemInfo.machine, "iPad2,"))
			_deviceName = iPad2;
		else if (strcmp("AppleTV2,1", systemInfo.machine) == 0)
			_deviceName = AppleTV;
#endif
		// Let's roll the stones
		Settings::alloc()->setScreenSize(self.view.bounds.size.height, self.view.bounds.size.width);;

		Bundle::alloc()->init([[[NSBundle mainBundle] bundlePath] cStringUsingEncoding:NSUTF8StringEncoding]);

		// Read current career state from the persistent store
		PlayerCareer::alloc()->restore();

		StateController::alloc();

		StateController::get()->_view = self.view;

//		rememberView(self.view);

		// Setup accelerometer
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0f / 60.0f];
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	}
	return self;
}

// The view controller calls this method when the view property is requested, but
// is currently nil.
- (void)loadView
{
    self.wantsFullScreenLayout = YES;
    BOOL highRes = NO;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        highRes = YES; // RETINA DISPLAY
    }

	self.view = [[EAGLView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
				 highRes:highRes];
}

// TODO: This must not be here, find out why crashes if calling from self init above
- (void)viewDidLoad {}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc. that aren't in use
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];

    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

// See what we should release here	
// Tear down context.
//    if ([EAGLContext currentContext] == context)
//        [EAGLContext setCurrentContext:nil];
//	self.context = nil;	
}

- (void)startAnimation
{
	if (!animating)
    {
		self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
		[displayLink setFrameInterval:60/kTargetFPS]; // Only integer here
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        animating = TRUE;

		assert(!eventLink);
		// In seconds
		self.eventLink = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(0.2) target:self selector:@selector(fireEvent:) userInfo:nil repeats:TRUE];

		assert(!eventOneHertz);
		// One hertz timer
		self.eventOneHertz = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(1.0) target:self selector:@selector(fireEventHertzOne:) userInfo:nil repeats:TRUE];
    }
}

- (void)stopAnimation
{
	if (animating)
	{
		[displayLink invalidate];
		self.displayLink = nil;
		animating = FALSE;

		[eventLink invalidate];
		self.eventLink = nil;
	}
}

- (void)fireEventHertzOne:(NSTimer*)theTimer
{
	if (StateController::get()->activeRenderer())
		StateController::get()->activeRenderer()->eventHertzOne();
}

- (void)fireEvent:(NSTimer*)theTimer
{
	if (StateController::get()->activeRenderer())
		StateController::get()->activeRenderer()->beat();
}

- (void)drawFrame
{
	[(EAGLView *)self.view setFramebuffer];

	StateController::get()->flow();

	[(EAGLView *)self.view presentFramebuffer];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if (StateController::get()->activeRenderer())
		StateController::get()->activeRenderer()->accel(acceleration.x, acceleration.y, acceleration.z);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch * touch in touches) // Seems to be always one iteration
	{
		CGPoint p = [touch locationInView:[self view]];
		StateController::get()->activeRenderer()->touchesBegan(p.x, p.y);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch * touch in touches)
	{
		CGPoint p = [touch locationInView:[self view]];
		StateController::get()->activeRenderer()->touchesMoved(p.x, p.y);
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch * touch in touches)
	{
		CGPoint p = [touch locationInView:[self view]];
		StateController::get()->activeRenderer()->touchesEnded(p.x, p.y);
	}
}

- (void)dealloc
{
	// Restore current career here from the persistent store
//	PlayerCareer::store();

	StateController::release();

	Bundle::release();
	Settings::release();

	[displayLink release];
	[eventLink release];

    [super dealloc];
}

@end
