/*
 *  VBO.h
 *  Kamikaze
 *
 *  Created by Hellcat on 5/2/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef VBO_H
#define VBO_H

#include <OpenGLES/ES2/gl.h> // For GL types

#include "iostream"
#include "map"
#import "macro.h"

struct MeshData
{
	MeshData() : vbo(0), indexVbo(0), vStride(0), nStride(0), texStride(0),
            tanStride(0), numFaces(0) {}

	// Vbo and accompanying data
	GLuint vbo, indexVbo, vStride, nStride, texStride, tanStride;
	GLubyte * vOffset, * nOffset, * texOffset, * tanOffset;
	GLuint numFaces;

	// For animation, taken directly from sdk
	//	CPODData sBoneIdx;		/*!< nNumBones*nNumVertex ints (Vtx0Idx0, Vtx0Idx1, ... Vtx1Idx0, Vtx1Idx1, ...) */
	//	CPODData sBoneWeight;	/*!< nNumBones*nNumVertex GLfloats (Vtx0Wt0, Vtx0Wt1, ... Vtx1Wt0, Vtx1Wt1, ...) */
	//	GLubyte * pInterleaved;	/*!< Interleaved vertex data */
	//	CPVRTBoneBatches sBoneBatches;	/*!< Bone tables */
private:
    //MeshData(const struct MeshData&) { implementMe(); }
};

// A class-replacer for mesh vbos. Represents one POD scene node
// Statically contains global map of all meshes loaded so far.
// Meshes are referenced by bodies ( Body::_meshes) and automatically used when
// body drawing, this is very efficient
class Mesh
{
	typedef std::pair<std::string, MeshData> Pair;
	typedef std::map<std::string, MeshData> Map;
public:
    //Mesh(const Mesh& src);
	Mesh(const char * meshName);
	~Mesh(); // Keep empty

	static bool preloadScene(const char * sceneName); // Load all models in the scene
	static void dump();
	static void release(); // Properly clear map (release all vbos)

	MeshData * _data; // References certain vbo within _map. Weak reference

    bool none;
    
private:
	static Map _map; // Map of all loaded models so far
};

#endif
