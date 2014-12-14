/*
 *  Texture.h
 *  Kamikaze
 *
 *  Created by Hellcat on 3/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef TEXTURE_H
#define TEXTURE_H

#include "constants.h" // For sampler constants

#include "iostream"
#include "map"

// Textures can be either PowerVR compressed (.pvr) or straight images (bmp, jpg, bmp)
// TODO: The maps search is done using default std::string comparing, which can be much slower than strcmp
class Texture
{
	typedef std::pair<std::string, GLuint> Pair;
	typedef std::map<std::string, GLuint> Map;
public:
	Texture(const char * texName = 0, bool clampToEdge = false);
	~Texture () { /* call release() to release all textures */ }

	// Use of -1 is a special case of doing nothing
	void use(GLbyte numTexUnit) const
	{
        if (_id == -1)
		{
            return;
        }
        glActiveTexture(GL_TEXTURE0 + numTexUnit); 
        glBindTexture(GL_TEXTURE_2D, _id); 
    }

	static void release(); // Final release of loaded textures

private:
	static bool load(const GLchar *, GLuint &, bool clampToEdge = false);
	GLuint _id; // The texture id registered by GL 
	static Map _map; // Single map containing all texture names (keys) and registered tex ids
};

#endif
