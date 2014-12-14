/*
 *  Body.cpp
 *  Kamikaze
 *
 *  Created by Hellcat on 2/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "Body.h"

// TODO: Consider moving world into separate file
#include "ActionRenderer.h" // For B2 World


Body::Body(float halfWidth, float halfHeight, float posZ) :
_halfWidth(halfWidth), _halfHeight(halfHeight), _posZ(posZ),
_ownMesh(false), _isOn(true)
{
}

Body::~Body()
{
	// If we haven't specified any model when body creating, we didn't create vbo in the map,
	// but we new'ed one vbo and so should release it here
	if (_ownMesh)
	{
		if (_meshes[0].mesh._data)
		{
			glDeleteBuffers(1, &_meshes[0].mesh._data->vbo);
			glDeleteBuffers(1, &_meshes[0].mesh._data->indexVbo);
			delete _meshes[0].mesh._data;
		}
		_meshes[0].mesh._data = 0;
	}
}

// Beware of improper use of static variables!
Body & Body::spinX(bool ownAngle, GLfloat deg, bool incrementAngle)
{
	static float r = 0.0f;
	MatrixManager::get()->rotate((ownAngle)?angle():0.0f + (incrementAngle)?r+=deg:deg, 1.0f, 0.0f, 0.0f);
	return * this;
}

Body & Body::spinY(bool ownAngle, GLfloat deg, bool incrementAngle)
{
	static float r = 0.0f;
	MatrixManager::get()->rotate((ownAngle)?angle():0.0f + (incrementAngle)?r+=deg:deg, 0.0f, 1.0f, 0.0f);
	return * this;
}

Body & Body::spinZ(bool ownAngle, GLfloat deg, bool incrementAngle)
{
	static float r = 0.0f;
	MatrixManager::get()->rotate((ownAngle)?angle():0.0f + (incrementAngle)?r+=deg:deg, 0.0f, 0.0f, 1.0f);
	return * this;
}

//Body & Body::spin(bool ownAngle, float degX, float degY, float degZ)
Body & Body::spin(bool ownAngle, float deg)
{
	MatrixManager::get()->rotate((ownAngle)?angle():0.0f + deg, 1.0f, 1.0f, 1.0f);
	return * this;
}

// TODO: Promote to provide indices as well, so we call glDrawElements()
Body & Body::addMesh(const char * meshName)
{
	_meshes.push_back(TexturedMesh(meshName));

	if (!meshName) // If passed mesh name is 0, create own mesh (not part of meshes map, so release in dtor)
	{
		_ownMesh = true;

		// Note, each new mesh gets auto closer to us by 0.01f meter (handy)
		const GLfloat v[] = // Prepare static data
		{
			-_halfWidth, -_halfHeight, _posZ+_meshes.size()/100.0f, // Position
			0.0f, 0.0f,	1.0f, // Normal
			0.0f, 0.0f, // UV

			_halfWidth, -_halfHeight, _posZ+_meshes.size()/100.0f,
			0.0f, 0.0f,	1.0f,
			1.0f, 0.0f,

			-_halfWidth, _halfHeight, _posZ+_meshes.size()/100.0f,
			0.0f, 0.0f,	1.0f,
			0.0f, 1.0f,

			_halfWidth, _halfHeight, _posZ+_meshes.size()/100.0f,
			0.0f, 0.0f,	1.0f,
			1.0f, 1.0f
		};
		MeshData * data = 0;
		data = new MeshData(); // For own vbo, create vbo in the heap (not in the map)
		data->vStride = 8 * sizeof(GLfloat);
		data->nStride = 8 * sizeof(GLfloat);
		data->texStride = 8 * sizeof(GLfloat);
		data->vOffset = (GLubyte *)(0);
		data->nOffset = (GLubyte *)(3 * sizeof(GLfloat));
		data->texOffset = (GLubyte *)(6 * sizeof(GLfloat));
		data->numFaces = 1; // Only one face

		glGenBuffers(1, &data->vbo);
		glBindBuffer(GL_ARRAY_BUFFER, data->vbo);
		glBufferData(GL_ARRAY_BUFFER, 4 * (8 * sizeof(GLfloat)), v, GL_STATIC_DRAW); // Four xy vertices
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		_meshes[_meshes.size()-1].mesh._data = data;
	}

	return * this;
}

Body & Body::setMesh(const char * meshName, byte meshIndex)
{
	// It is up to you to overrange and awfully die here, deliberately no any checks
	_meshes[meshIndex] = TexturedMesh(meshName);
	return * this;
}

// TODO: Enhance to include rotation, add drawr() or like
// Deliberately not placing push/popMatrix here to allow extra transformations in underlying code.
// As a direct result - always push/pop in case you apply any extra transformation
// For speed - intentionally not placing useProgram here, as we can use the same for several bodies
Body & Body::draw(bool addOwnPos, float adjX, float adjY, float adjZ)
{
	if (!_isOn)
		return * this;

	shouldDie();

	// TODO: Automatically use relevant shader here?

	if (addOwnPos)
		MatrixManager::get()->translate(posX()+adjX, posY()+adjY, adjZ);
	else
		MatrixManager::get()->translate(adjX, adjY, adjZ);

	// TODO: We always pass all matrices. This is *not* needed for all shaders
	glUniformMatrix4fv(ShaderManager::get()->program()->uniforms[uniMatrixProjModelView], 1, GL_FALSE, MatrixManager::get()->matrixProjModelView()); // No transformations below this
	glUniformMatrix4fv(ShaderManager::get()->program()->uniforms[uniMatrixModelView], 1, GL_FALSE, MatrixManager::get()->matrixModelView());
	glUniformMatrix3fv(ShaderManager::get()->program()->uniforms[uniMatrixModelViewIT], 1, GL_FALSE, MatrixManager::get()->matrixModelViewIT());

	// For short references
	static const MeshData * vbo = 0;
	static TexturedMesh::Textures * texUnits;
	static TexturedMesh::Textures::iterator texIt;
	static Meshes::iterator meshIt;
	static GLbyte i;

	// For each body mesh
	for (meshIt=_meshes.begin(); meshIt!=_meshes.end(); ++meshIt)
	{
		texUnits = &meshIt->texUnits;

		// Enable mesh-relevant textures
		for (texIt=texUnits->begin(), i=0; texIt!=texUnits->end(); ++texIt, ++i) texIt->use(i);

		vbo = meshIt->mesh._data;
		glBindBuffer(GL_ARRAY_BUFFER, vbo->vbo); // Never forget to unbind when done
		glVertexAttribPointer(VERTEX_ARRAY, 3, GL_FLOAT, GL_FALSE, vbo->vStride, vbo->vOffset);
		glVertexAttribPointer(NORMAL_ARRAY, 3, GL_FLOAT, GL_FALSE, vbo->nStride, vbo->nOffset);
		glVertexAttribPointer(TEXCOORD_ARRAY, 2, GL_FLOAT, GL_FALSE, vbo->texStride, vbo->texOffset);

		// And draw the body
		// TODO: Promote to indexed, the unindexed draw seems to be decreasing render speed
		if (_ownMesh)
		{
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		}
		else
		{ // For bodies that are tied to complex POD meshes
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo->indexVbo);
			glEnableVertexAttribArray(TANGENT_ARRAY); // Guarranty we enable tangents
			glVertexAttribPointer(TANGENT_ARRAY, 3, GL_FLOAT, GL_FALSE, vbo->tanStride, vbo->tanOffset);
			glDrawElements(GL_TRIANGLES, vbo->numFaces*3, GL_UNSIGNED_SHORT, 0);
			glDisableVertexAttribArray(TANGENT_ARRAY); // And disable them after draw
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		}
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	return * this;
}

Body & Body::place(bool addOwnPos, GLfloat adjX, GLfloat adjY, GLfloat adjZ)
{
	if (addOwnPos)
		MatrixManager::get()->translate(posX()+adjX, posY()+adjY, /*_posZ*/+adjZ);
	else
		MatrixManager::get()->translate(adjX, adjY, adjZ);
	return * this;
}
