/*
 *  VBO.cpp
 *  Kamikaze
 *
 *  Created by Hellcat on 5/2/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "Mesh.h"

// PowerVR utilities
#include "PowerVRTools/PVRTModelPOD.h" // The .pod scene parse routines

#include "Misc.h" // For bundle

#include "constants.h" // For error codes

#define MESH_DUMP_ENABLED

Mesh::Map Mesh::_map; // Init static variable

// Deliberately leave dtor empty, as we're deep copying Model when creating bodies.
// The deep copying is ok, because the class size is measerable.
// As a result, call specific method to properly clear the map
Mesh::~Mesh() { /* keep me empty*/ }

#if 0
Mesh::Mesh(const Mesh& src)
    : _data(/*weak*/src._data)
{}
#endif

void Mesh::release()
{
	// Iterate all created vbos and release every
	for (Map::iterator it = _map.begin(); it!=_map.end(); ++it)
	{
		glDeleteBuffers(1, &it->second.vbo);
		glDeleteBuffers(1, &it->second.indexVbo);
	}
	_map.clear(); // Very important
}

// If you know for sure that model has already been loaded - just provide the model name.
// TODO: Always preload models using preloadScene()!
Mesh::Mesh(const char * meshName) : _data(0)
{
	if (!meshName || !*meshName) { // If meshName is 0, just return, own vbo will be created later
        none = true;
		return;
    }

    none = false;

	// See if this model has been loaded already
	Map::iterator it;
	it = _map.find(meshName);

	if (it != _map.end())
	{ // Model found in the map, reference it
		_data = &it->second;
	}
	else
	{ // Model not found
		printf("WARNING! Model %s not found in the map (make sure you've it preloaded)!\n", meshName);
	// TODO: Actually in this case we need to parse scene file and read model from it, but
	// this raises a number of questions to resolve, so for now always preload models
//		_vbo = 0;
	}
}

void Mesh::dump()
{
#ifdef MESH_DUMP_ENABLED
	printf("======= Dumping models map...\n");
		Map::iterator it;
		for (it = _map.begin(); it!=_map.end(); ++it)
			printf("Key: %s, _vbo: %p, vbo: %d, indexVbo: %d\n",
				   it->first.c_str(), &it->second,
				   it->second.vbo, it->second.indexVbo);
	printf("=============================\n");
#endif
}

// Preload models from the specified .pod scene
bool Mesh::preloadScene(const char * sceneName)
{
	if (!sceneName || !*sceneName)
	{
		return false;
    }

	// This structure must later be destroyed with PVRTModelPODDestroy() to prevent memory leaks.
	CPVRTModelPOD scene;
	if (scene.ReadFromFile((Bundle::get()->path() + sceneName).c_str()) != PVR_SUCCESS)
	{
		printf("ERROR: Failed to load scene: %s\n", sceneName);
		return false;
	}

	printf("========== Scene %s details:\n", sceneName);
	printf("= Meshes: %d\n", scene.nNumMesh);
	printf("= Nodes: %d\n", scene.nNumNode);
	printf("= Mesh Nodes: %d\n", scene.nNumMeshNode);
	printf("= Lights: %d\n", scene.nNumLight);
	printf("= Cameras: %d\n", scene.nNumCamera);
	printf("= Textures: %d\n", scene.nNumTexture);
	printf("= Materials: %d\n", scene.nNumMaterial);
	printf("= Frames: %d\n", scene.nNumFrame);

	// Iterate through nodes, its wiser than traverse meshes.
	// PowerVR SDK: Meshes may be instanced several times in a scene;
	// i.e. different Nodes may reference any given mesh.
	// nNumMeshNode: Number of items in the array pNode which are objects
	static GLuint i; // External because used outside loop for success check
	for (i = 0; i < scene.nNumMeshNode; ++i)
	{
		SPODNode & meshNode = scene.pNode[i];
		SPODMesh & mesh = scene.pMesh[meshNode.nIdx];
		GLuint uiSize = mesh.nNumVertex * mesh.sVertex.nStride;

		// Load vertex data into buffer object
		MeshData vbo;
		glGenBuffers(1, &vbo.vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo.vbo);
		glBufferData(GL_ARRAY_BUFFER, uiSize, mesh.pInterleaved, GL_STATIC_DRAW);

		// Remember strides and offsets
		vbo.vStride = mesh.sVertex.nStride;
		vbo.nStride = mesh.sNormals.nStride;
		vbo.texStride = mesh.psUVW[0].nStride;
		vbo.tanStride = mesh.sTangents.nStride;

		vbo.vOffset = mesh.sVertex.pData;
		vbo.nOffset = mesh.sNormals.pData;
		vbo.texOffset = mesh.psUVW[0].pData;
		vbo.tanOffset = mesh.sTangents.pData;
		vbo.numFaces = mesh.nNumFaces;

		// Load index data (if any) into buffer object
		vbo.indexVbo = 0;
		if (mesh.sFaces.pData)
		{
			uiSize = PVRTModelPODCountIndices(mesh) * sizeof(GLshort);
			glGenBuffers(1, &vbo.indexVbo);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo.indexVbo);
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, uiSize, mesh.sFaces.pData, GL_STATIC_DRAW);
		}

		// Insert just read node into the map
//		printf("Adding %s\n", MeshNode.pszName);
		_map.insert(Pair(std::string(meshNode.pszName), vbo));

		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	}
	(i==scene.nNumMeshNode)?printf("Scene loaded OK"):printf("Scene loaded partially");
	printf(" (%d of %d nodes added)\n", i, scene.nNumMeshNode);
	printf("===========\n\n");

//	dump();

	return true;
};
