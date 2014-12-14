/*
 *  constants.h
 *  Kamikaze
 *
 *  Created by Hellcat on 1/11/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <OpenGLES/ES2/gl.h> // For GL types

typedef signed char byte;
typedef unsigned int uint;

#define noAction 0 // Pass in when widget is not going to have any associated touch handlers
enum {eActionNo=0, eActionYes}; // Keep one handler for popups, differentiate by tag

// The iOS devices, http://en.wikipedia.org/wiki/List_of_iOS_devices
// Note we dont support non-shader devices, these are: iPodTouch1, iPodTouch2, iPhone, iPhone3G
enum
{
	DeviceUnknown=-1, Simulator=0,
	iPodTouch, iPodTouch2, iPodTouch3, iPodTouch4,
	AppleTV,
	iPhone, iPhone3G, iPhone3GS, iPhone4,
	iPad, iPad2
};

// Multitouch
enum { X=0, Y=1, Z=2, XY=2, XYZ=3 };
#define kMaxMultTouchesAllowed 2 // TODO: Increase if becomes necessary

// Screen, in meters
#define kSceneWidth		20.0f
#define	kSceneHeight	15.0f

// OpenGL
#define kBitsPerPixel			32	// OpenGL scene bits per pixel. Should be <= 32
#define kTargetFPS				60	// Maximum fixed FPS for the scene, can never be higher. Should be <= 60
#define kDepthBufferEnabled		1	// Is depth buffer enabled or not
#define kFullScreenAntiAliasing 0	// Full screen anti-aliasing, possible values: 0 - off, 2 - 2x, 4 - 4x.

// Objects' default scene depth location
#define kDepthHUD		5.0f
#define kDepthBack		-5.0f


// Error codes, application wide
enum
{
	kErrSuccess = 0,
	kErrBadAllocation,
	kErrTextureBadFilename,
	kErrTextureLoadFail,
	kErrBundleInitFail,
	kErrXMLBadFilename,
	kErrXMLReadFail,
	kErrMeshBadFilename,
	kErrPODSceneBadFilename,
	kErrPODSceneReadFail
};

#define	RAND_LIMIT	32767 // For Core::randomFloat()


#endif
