/*
 *  Misc.h
 *  Kamikaze
 *
 *  Created by Hellcat on 3/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef MISC_H
#define MISC_H


#include "Singleton.h"
#include "string"

#include "constants.h"

#include "Box2D/Box2D.h" // We're defining World here


// this is the solution for presetting screen coordinates -
//  - items could be precisely set onto their places by maximum 9 iterations
//    of debug runs.
//
// The method is simple: you need to make a binary search by presetting bits 
//  from higer to lower to do the fit.
// 
// Any number between 0 and 1023 could be accessed
//
// At instance, 1010100001 -> 2^9 + 2^7 + 2^5 + 2^0 = 512 + 128 + 32 + 1 =
//  = 673
//
// Because it is a const-function, it will be optimised to simple putting its 
//  result value in place of call.
inline const int bitcoord(const unsigned int bitargs) {
    int mask = 0x400, result = 0, bits = bitargs;
    
    for (int i = 0; i < 10; i++, bits /= 10) {
        result |= (bits % 10 == 0 ? 0 : mask);
        result >>= 1;
    }

    return result;
}

// This singleton is solely for representing the app bundle directory path.
// Should be used to reference any app resource
class BundlePath
{
public:
	BundlePath() : _path("") {};
	~BundlePath() { /* nothing to release */ };
	void init(const char * bundlePath)
	{
		_path = bundlePath;
		_path += '/';
	}
	const std::string & path() const { return _path; }

private:
	std::string _path; // The application bundle path
};
typedef Singleton<BundlePath> Bundle;

class _Settings
{
public:
	_Settings() : _screenWidth(0.0f), _screenHeight(0.0f), _meterFactor(0.0f), _pixelFactor(0.0f) {}
	~_Settings() {}

	void setScreenSize(float screenWidth, float screenHeight)
	{
		_screenWidth = screenWidth;
		_screenHeight = screenHeight;
		_pixelFactor = screenWidth/kSceneWidth;
		_meterFactor = kSceneWidth/screenWidth;
	}
	const float screenWidth() const { return _screenWidth; }
	const float screenHeight() const { return _screenHeight; }
	const float pixelFactor() const { return _pixelFactor; }
	const float meterFactor() const { return _meterFactor; }

private:
	float _screenWidth, _screenHeight; // Screen size in pixels
	float _meterFactor; // Multiply pixel coords by this to obtain coords in meters
	float _pixelFactor; // Multiply meter coords by this to get coords in pixels
};
typedef Singleton<_Settings> Settings;

// Box2D is tuned for MKS units. Keep the size of moving objects roughly between 0.1 and 10 meters.
// Small inheritance hack to become singleton
// TODO: Move to Misc.h
class _World : public b2World
{
public:
	_World() : b2World(b2Vec2(0.0f, 0.0f), false) {};
};
typedef Singleton<_World> World;

#endif
