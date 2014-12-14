//
//  BodyBox2d.h
//  Kamikaze
//
//  Created by Max Reshetey on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef BODY_BOX2D_H
#define BODY_BOX2D_H

#include "Body.h"

// Class representing one Box2d physical object, simply a rectangle-formed body.
// Derive from it, if you want bodies with complex shapes

// Notes:
// - When a world leaves scope or is deleted by calling delete on a pointer, all the memory
//   reserved for bodies, fixtures, and joints is freed. This is done to make your life easier.
//   However, you will need to nullify any body, fixture, or joint pointers you have because they will become invalid.
// - When you create a b2Bodyor a b2Joint, you need to call the factory functions on b2World.
//   You should never try to allocate these types in another manner.
// - When a body is destroyed, all shapes and joints attached to the body are automatically destroyed.
//   You must nullify any pointers you have to those shapes and joints. Otherwise, your program
//   will die horribly if you try to access or destroy those shapes or joints later.
class BodyBox2d : public Body
{
protected:
	// Completer ctor, used when creating body in a heap
	BodyBox2d(float halfWidth, float halfHeight, float posX=0.0f, float posY=0.0f, float density=0.8f); // Called by kids only

	// Default ctor, instead of default parameters for the full ctor (error prone)
	BodyBox2d();

public:
	// Create body with basic shape: circle, box
	BodyBox2d(eBodyType type, eBodyShape shape, GLfloat halfWidth, GLfloat halfHeight, GLfloat posX=0.0f, GLfloat posY=0.0f, GLfloat density=0.8f, GLfloat restitution=0.8f);

	// Create body with complex shape
	BodyBox2d(GLfloat shape[][XY], GLbyte vertexCount, GLfloat posX, GLfloat posY, GLfloat density=0.8f);
	virtual ~BodyBox2d(); // Allow public destruction

	virtual const GLfloat posX() const { return mB2Body->GetPosition().x; }
	virtual BodyBox2d & setPosX(GLfloat posX) { mB2Body->SetTransform(b2Vec2(_initialOffsetX+posX, posY()), 0.0f); return * this; }

	virtual const GLfloat posY() const { return mB2Body->GetPosition().y; }
	virtual BodyBox2d & setPosY(GLfloat posY) { mB2Body->SetTransform(b2Vec2(posX(), _initialOffsetY+posY), 0.0f); return * this; }
	
//	virtual BodyBox2d & setPos(float posX, float posY) { _posX=posX; _posY=posY; return * this; }

	virtual const GLfloat angle() const { return ((GLfloat)mB2Body->GetAngle() * (180.0f/M_PI)); }
	virtual void setAngle(GLfloat degrees) {};

	virtual BodyBox2d & draw(bool addOwnPos = true, GLfloat adjX = 0.0f, GLfloat adjY = 0.0f, GLfloat adjZ = 0.0f);

	virtual BodyBox2d & ddraw(bool addOwnPos = true, bool drawJoint = false);
	
	virtual void shouldDie();
	
	const b2Vec2 velocity() const { return mB2Body->GetLinearVelocity(); }
	GLvoid angularImpulse(GLfloat impulse) { mB2Body->ApplyAngularImpulse(impulse); }
	GLvoid linearImpulse(GLfloat forceX, GLfloat forceY, GLfloat offsetX = 0.0f, GLfloat offsetY = 0.0f);
	virtual void force(float forceX);

	GLvoid resetSpeed() { mB2Body->SetLinearVelocity(b2Vec2(0.0f, 0.0f)); mB2Body->SetAngularVelocity(0.0); }
	GLvoid resetPositon() { mB2Body->SetTransform(b2Vec2(0.0f, 0.0f), 0.0f); }
	GLvoid createDistanceJoint(GLfloat offsetX, GLfloat offsetY, BodyBox2d * bodyB, GLfloat offsetBX = 0.0f, GLfloat offsetBY = 0.0f, GLfloat frequencyHz = 1.0f);
	GLvoid createRevoluteJoint(GLfloat localX, GLfloat localY, BodyBox2d * bodyB, GLfloat localBX = 0.0f, GLfloat localBY = 0.0f);
	
	b2Body * b2body() { return mB2Body; }
	const b2RevoluteJoint * joint() const { return mJoint; };
	
	GLvoid adjJointLimit(GLfloat limit) { if (mJoint) { mJointLimit+=limit; mJoint->SetLimits(-mJointLimit, mJointLimit); } }
	GLvoid removeJoint();
	
	GLfloat health() { return mHealth; }
	GLvoid setHealth(GLfloat health) { mHealth = health; }
	GLvoid adjHealth(GLfloat health) { if (mHealth>10.0f) mHealth += health; }
	GLvoid checkAlive();
	
	const byte shape() const { return _shape; }
	void setScale(float scale) { _scaleBy = scale; };
	
protected: // Variables
	//	b2World * mB2World; // The single b2World (don't destroy in dtor!)
	b2Body * mB2Body; // Box2d associated body (destroy in dtor)
	GLfloat mHealth; // Body's health (initially is 100.0f)
	b2RevoluteJoint * mJoint; // Body's associated revolute joint
	GLfloat mJointLimit; // The max angle of the joint revolution (inititally 0.0f)
	byte _shape; // Body's shape, used in the contact solver to work out what body
	float _scaleBy;
	
	float _initialOffsetY, _initialOffsetX;
private:
    BodyBox2d(const BodyBox2d& src) : Body(src) { implementMe(); }
};

// Class to represent an airplane, redefines logic of creation body shapes, because airplane is a complex object
// TODO: Consider promote to smth like Vehicle, if proves the same for all transport bodies
class Airplane : public BodyBox2d
{
	friend class ActionRenderer;
	friend class AirplanePainter;
    Airplane(const Airplane&) { implementMe(); }
    
public:
	Airplane(GLfloat halfWidth, GLfloat halfHeight, GLfloat posX = 0.0f, GLfloat posY = 0.0f, float density = 0.8f);
	virtual ~Airplane();
	virtual Airplane & setPosX(float posx);
	virtual Airplane & setPosY(float posy); // This is overloaded to move holders instead
	
	virtual Airplane & ddraw(bool addOwnPos = true, bool drawJoint = false);
	virtual Airplane & draw(bool addOwnPos = true, GLfloat adjX = 0.0f, GLfloat adjY = 0.0f, GLfloat adjZ = 0.0f);
	
	enum { A=0, B, C, D, eNumJetHolders };
	BodyBox2d * _holders[eNumJetHolders];
	
	BodyBox2d * &operator [](GLbyte eJetPart) { return _parts[eJetPart]; }
	
	virtual void force(float forceX);
	
	//	enum JetParts { eJetPropeller=0, eJetPilot, eJetGun, eJetWings, eJetTail, eNumJetParts };
	enum JetParts { eJetPropeller=0, eJetWings, eJetTail, eNumJetParts };
private:
	BodyBox2d * _parts[eNumJetParts]; // Attached parts
};

#endif
