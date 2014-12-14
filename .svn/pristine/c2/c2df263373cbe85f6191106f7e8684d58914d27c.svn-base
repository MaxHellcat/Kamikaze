/*
 *  Texture.cpp
 *  Kamikaze
 *
 *  Created by Hellcat on 3/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "Texture.h"
#include "Misc.h" // For Bundle
#include "constants.h"

#include "./PowerVRTools/OGLES2/PVRTTextureAPI.h" // Textures

Texture::Map Texture::_map; // Init static variable


// TODO: Enhance to accept std::string as well
Texture::Texture(const char * texName, bool clampToEdge) : _id(0)
{
    if (!texName || !*texName) { _id = -1; return; } // If passed null, just do nothing

	char * p = const_cast<char *>(texName);
	while (*++p && *p!='.'); // Search for dot or \0

	std::string name(texName);
	if (*p == 0) name += ".pvr"; // If reached eos, we've no file extension, make it .pvr

	static Map::iterator it;
	it = _map.find(name);
	if (it == _map.end())
	{
		if (!load(name.c_str(), _id, clampToEdge)) { throw kErrTextureLoadFail; }
		_map.insert(Pair(name, _id));
//		printf("Texture NOT found, adding <%s, %d>\n", name.c_str(), mId);
	}
	else
	{
//		printf("Texture found: <%s, %d>\n", it->first.c_str(), it->second);
		_id = it->second;
	}
}

// TODO: Find out why mipmapping doesnt work!
// TODO: Uncompressed load doesn't work for 16 bits per pixel GL mode
bool Texture::load(const GLchar * texName, GLuint & texId, bool clampToEdge)
{
	char * p = const_cast<char *>(texName);
	while (*++p != '.'); // Search for dot

	if (strcmp(p, ".pvr") == 0) // Load compressed texture (allow file without extension)
	{
		if (PVRTTextureLoadFromPVR((Bundle::get()->path() + texName).c_str(), &texId) != PVR_SUCCESS)
		{
			printf("ERROR: Failed to load PVR texture %s\n", texName);
			if (texId) glDeleteTextures(1, &texId); texId = 0;
			return false;
		}
	}
	else // Load uncompressed
	{
		glGenTextures(1, &texId);
		glBindTexture(GL_TEXTURE_2D, texId);

		NSString * nsImageName = [NSString stringWithCString:texName encoding:NSUTF8StringEncoding];
		UIImage * image = [UIImage imageNamed:nsImageName];
		if (image == nil)
		{
			printf("ERROR: Failed to load texture %s\n", texName);
			if (texId) glDeleteTextures(1, &texId); texId = 0;
			return false;
		}

		const GLuint imageWidth = (GLuint)image.size.width;
		const GLuint imageHeight = (GLuint)image.size.height;

		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		void * data = malloc(imageHeight * imageWidth * kBitsPerPixel/8); // Cross fingers!
		if (!data)
		{
			printf("ERROR: Failed to load texture %s\n", texName);
			CGColorSpaceRelease(colorSpace);
			if (texId) glDeleteTextures(1, &texId); texId = 0;
			return false;
		}

		CGContextRef textureContext = CGBitmapContextCreate(data, imageWidth, imageHeight, 8, kBitsPerPixel/8 * imageWidth,
															colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		// Flip texture vertically
		CGContextTranslateCTM (textureContext, 0, imageHeight);
		CGContextScaleCTM (textureContext, 1.0f, -1.0f);

		CGColorSpaceRelease(colorSpace);

		CGContextClearRect(textureContext, CGRectMake(0, 0, imageWidth, imageHeight));
		CGContextDrawImage(textureContext, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
		CGContextRelease(textureContext);

		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	}

	// TODO: Consider passing these as parameters, in case ever need varying
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	if (clampToEdge)
	{
		// Prevent tearing edges 
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}

	return true;
}

void Texture::release()
{
	for (Map::iterator it = _map.begin(); it!=_map.end(); ++it)
	{
		glDeleteTextures(1, &it->second); it->second = 0;
	}
	_map.clear(); // Very important
}
