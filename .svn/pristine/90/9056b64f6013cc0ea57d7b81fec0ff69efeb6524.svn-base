//
//  KamikazeAppDelegate.m
//  Kamikaze
//
//  Created by Max Reshetey on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KamikazeAppDelegate.h"

#import "EAGLView.h"

#import "KamikazeViewController.h"

@implementation KamikazeAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Window
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	if (_window == nil)
	{
		NSLog(@"Failed to create application window");
		[self release];
		return NO;
	}

	// View Controller (it creates view)
	_viewController = [[KamikazeViewController alloc] init];
	if (_viewController == nil)
	{
		NSLog(@"Failed to create View Controller");
		[self release];
		return NO;
	}

//	_window.rootViewController = _viewController; // Available since iOS 4.0

	[_window addSubview:[_viewController view]];
	[_window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:600.0f];
	[_viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0f / 60.0f];
	[_viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
    // AGL: I'm not sure you need to waste any cpu cycles stopping animation
	[_viewController stopAnimation];
}

- (void)dealloc
{
	[_window release];
	[_viewController release];
    [super dealloc];
}

@end
