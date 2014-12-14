/*
 *  Body.h
 *  Kamikaze
 *
 *  Created by Hellcat on 2/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef BODY_H
#define BODY_H

#include "Box2D/Box2D.h"

#include "PVRTModelPOD.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "Mesh.h"

#include "Shader.h"
#include "Matrix.h"

#include "Texture.h"
#include "vector"

#include "Singleton.h"

#include "Misc.h" // For settings
#import "macro.h"
class AirplanePainter;

typedef enum { eBodyTypeDynamic = 0, eBodyTypeStatic, eBodyTypeSimple } eBodyType;

// Split this to enumerate exact figures, Cone, Cylinder, etc
typedef
enum
{
	eBodyShapeBox = 0,
	eBodyShapeCircle,
	eBodyShapeComplex,
	eBodyShapeAirplane,
} eBodyShape;

// Tiny class body-helper representing one mesh and relevant textures to draw it.
// Main purpose is to allow body to be composed of multiple meshes.
// E.g. we can have body Wing, consisting of separate left and right wing meshes,
// behaving identically within the body.
struct TexturedMesh
{
	typedef std::vector<Texture> Textures;
    TexturedMesh(const TexturedMesh&src) : mesh(src.mesh), texUnits(src.texUnits) {}
public:
	// If meshName is 0, we will create own mesh (not part of Mesh:_map)
	TexturedMesh(const char * meshName=0) : mesh(meshName) { /* Usual callflow*/ };
	Mesh mesh;
	Textures texUnits;
};

// Abstract body, interface. Any other body in the game must be derived from it
// TODO: Implement TTL logic ASAP
class Body
{
protected:
	typedef std::vector<TexturedMesh> Meshes;
	Body(float halfWidth, float halfHeight, float posZ);
//	Body(); // Special case
	virtual ~Body();
    Body(const Body&) { implementMe(); }

// TODO: Move relevant methods (e.g. virtual) into protected section
// TODO: Try to split methods with 'if' cases into smaller, but without branching
public: // Methods
	virtual const float posX() const = 0;
	virtual Body & setPosX(float posX) = 0;

	virtual const float posY() const = 0;
	virtual Body & setPosY(float posY) = 0;

	float posZ() const { return _posZ; }
	Body & setPosZ(float posZ) { _posZ = posZ; return * this; }

	virtual const float angle() const = 0;
	virtual void setAngle(float degrees) = 0;

	// Set body frame, if passed height is zero, make height = width
	virtual Body & setSize(float halfWidth, float halfHeight = 0.0f) { _halfWidth = halfWidth; (halfHeight)?_halfHeight=halfHeight:_halfHeight=halfWidth; return * this; }
	virtual Body & setPos(float posX, float posY) { setPosX(posX); setPosY(posY); return * this; }

	Body & spin(bool ownAngle = true, float deg = 0.0f);
	Body & spinX(bool ownAngle = true, float deg = 0.0f, bool incrementAngle = false);
	Body & spinY(bool ownAngle = true, float deg = 0.0f, bool incrementAngle = false);
	Body & spinZ(bool ownAngle = true, float deg = 0.0f, bool incrementAngle = false);

	Body & scale(float scaleBy) { MatrixManager::get()->scale(scaleBy, scaleBy, scaleBy); return * this; } 

	virtual void shouldDie() = 0; // Differs for bodies
	const bool isOn() const { return _isOn; }

	Body & addMesh(const char * meshName = 0); // Attach new mesh to body, name 0 means own vbo
	Body & setMesh(const char * meshName, byte meshIndex = 0);

	// These two below only deal with the rightmost mesh in the _meshes
	Body & setTexture(const char * texName, bool clampToEdge=false)
	{
		_meshes[_meshes.size()-1].texUnits[0] = Texture(texName, clampToEdge);
	
		return * this;
	}
	virtual Body & addTexture(const char * texName, bool clampToEdge=false)
	{
		_meshes[_meshes.size()-1].texUnits.push_back(Texture(texName, clampToEdge));
		return * this;
	}
	Body & addTextureForMesh(const char * texName, byte meshIndex=0)
	{ // It is up to you to overrange and die here, no any checks
		_meshes[meshIndex].texUnits.push_back(Texture(texName, false));
		return * this;
	}


	virtual Body & push() { MatrixManager::get()->pushMatrix(); return * this; }
	Body & pop() { MatrixManager::get()->popMatrix(); return * this; }

	// Drawing section
	virtual Body & ddraw(bool addOwnPos = true, bool drawJoint = false) = 0; // Debug draw, visualise body's frame
	virtual Body & draw(bool addOwnPos=true, float adjX=0.0f, float adjY=0.0f, float adjZ=0.0f); // Only internally

	Body & place(bool addOwnPos = true, GLfloat adjX = 0.0f, GLfloat adjY = 0.0f, GLfloat adjZ = 0.0f);

    TexturedMesh * meshes(GLbyte index) { return _meshes.size() > index ? &_meshes[index] : 0; }

    float halfWidth() const { return _halfWidth; }
    float halfHeight() const { return _halfHeight; }
protected: // Variables
	float _halfWidth, _halfHeight; // These define body frame in case of own vbo
	float _posZ; // Since we have 2D scene, this is purely for proper alpha blending
	bool _ownMesh; // If true, we create own mesh
	Meshes _meshes; // Array of meshes attached to body
	bool _isOn; // Is the body within a screen area
};

#endif
