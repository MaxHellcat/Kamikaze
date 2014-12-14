//
//  BodyBox2d.cpp
//  Kamikaze
//
//  Created by Max Reshetey on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "BodyBox2d.h"

#include "PlayerCareer.h" // Current upgrades

#include "chain.h"

// Main ctor, must be used for public body creation
BodyBox2d::BodyBox2d(eBodyType type, eBodyShape shape, float halfWidth, float halfHeight,
					 float posX, float posY, float density, GLfloat restitution) :
Body(halfWidth, halfHeight, 0.0f),
mB2Body(0),
mHealth(100.0f),
mJoint(0),
mJointLimit(0.0f),
_shape(shape),
_scaleBy(1.0f),
_initialOffsetX(posX),
_initialOffsetY(posY)
{
	bool isDynamic = (type == eBodyTypeDynamic)?true:false;
	bool isCircle = (shape == eBodyShapeCircle)?true:false;;

	// Alloc the world here, as we may create body in the Renderer ctor init list
	// TODO: Consider adding init() method in the class
	if (!World::get()) World::alloc();

	b2BodyDef bodyDef;
	if (isDynamic) bodyDef.type = b2_dynamicBody;  // Must set the body type to b2_dynamicBody if you want the body to move in response to forces.
	bodyDef.position.Set(posX, posY);
	mB2Body = World::get()->CreateBody(&bodyDef);

	mB2Body->SetUserData(this); // Remember reference to us
	
	b2FixtureDef fixtureDef;
	b2PolygonShape box;
	b2CircleShape circle;
	if (isCircle)
    {
        circle.m_radius = halfWidth; fixtureDef.shape = &circle;
    }
	else { box.SetAsBox(halfWidth, halfHeight); fixtureDef.shape = &box; }
	if (isDynamic) fixtureDef.density = density; // Kg/m2
	//	if (isDynamic) fixtureDef.friction = 0.1f; else fixtureDef.friction = 0.0f;
	fixtureDef.friction = 0.7f;
	fixtureDef.restitution = restitution; // Body elasticity, good for left gravitation
	mB2Body->CreateFixture(&fixtureDef);
}

BodyBox2d::BodyBox2d(GLfloat halfWidth, GLfloat halfHeight, GLfloat posX, GLfloat posY, GLfloat density) :
Body(halfWidth, halfHeight, 0.0f),
mB2Body(0),
mHealth(100.0f),
mJoint(0),
mJointLimit(0.0f),
_shape(0),
_scaleBy(1.0f),
_initialOffsetX(posX),
_initialOffsetY(posY)
{
	/* Keep empty, used by kids to override body creation, e.g. by airplane */
};

BodyBox2d::BodyBox2d() :
Body(0.0f, 0.0f, 0.0f),
mB2Body(0),
mHealth(100.0f),
mJoint(0),
mJointLimit(0.0f),
_shape(0),
_scaleBy(1.0f),
_initialOffsetX(0.0f),
_initialOffsetY(0.0f)

{
} // Called by kids only

// Complex Box2d body
BodyBox2d::BodyBox2d(GLfloat shape[][XY], GLbyte vertexCount, GLfloat posX, GLfloat posY, GLfloat density) :
Body(0.0f, 0.0f, 0.0f),
mB2Body(0),
mHealth(100.0f),
mJoint(0),
mJointLimit(0.0f),
_shape(eBodyShapeComplex),
_scaleBy(1.0f),
_initialOffsetX(posX),
_initialOffsetY(posY)
{
	bool isDynamic = true;
	
	b2BodyDef bodyDef;
	if (isDynamic) bodyDef.type = b2_dynamicBody;  // Must set the body type to b2_dynamicBody if you want the body to move in response to forces.
	bodyDef.position.Set(posX, posY);
	mB2Body = World::get()->CreateBody(&bodyDef);
	
	mB2Body->SetUserData(this); // Remember reference to us
	
	b2FixtureDef fixtureDef;
	b2PolygonShape box;
	
	// You must create polygons with a counter clockwise winding (CCW)
	b2Vec2 vec[8];
	for (GLbyte i=0; i<vertexCount; ++i)
	{
		vec[i] = b2Vec2(shape[i][X], shape[i][Y]);
	}
	box.Set(vec, vertexCount);
	fixtureDef.shape = &box;
	
	fixtureDef.density = density; // Kg/m2
	fixtureDef.friction = 0.1f;
	fixtureDef.restitution = 0.8f; // Body elasticity
	mB2Body->CreateFixture(&fixtureDef);
}

// Destroying the world automatically destroys all bodies, so nothing to destruct (apart any other non-Box2d allocations)
BodyBox2d::~BodyBox2d()
{
	/*
	 if (mB2Body)
	 {
	 World::get()->DestroyBody(mB2Body); // This also deletes attached joints
	 mB2Body = 0;
	 mJoint = 0;
	 }
	 */
}

BodyBox2d & BodyBox2d::draw(bool addOwnPos, float adjX, float adjY, float adjZ)
{
	if (_scaleBy > 1.0f)
		MatrixManager::get()->scale(_scaleBy, _scaleBy, _scaleBy);
	Body::draw(addOwnPos, adjX, adjY, adjZ); return * this;
}

void BodyBox2d::linearImpulse(GLfloat forceX, GLfloat forceY, GLfloat offsetX, GLfloat offsetY)
{
	mB2Body->ApplyLinearImpulse(b2Vec2(forceX, forceY), b2Vec2(mB2Body->GetWorldCenter().x+offsetX, mB2Body->GetWorldCenter().y+offsetY));
}

void BodyBox2d::force(float forceX)
{
	mB2Body->ApplyForce(b2Vec2(forceX, 0.0f), mB2Body->GetWorldCenter());
//	mB2Body->SetLinearVelocity(b2Vec2(forceX, 0.0f));
}

// Create joint between self and bodyB
void BodyBox2d::createDistanceJoint(GLfloat offsetX, GLfloat offsetY, BodyBox2d * bodyB, GLfloat offsetBX, GLfloat offsetBY, GLfloat frequencyHz)
{
	b2DistanceJointDef joint;
	b2Vec2 p1, p2, d;
	
	joint.frequencyHz = frequencyHz; // Rope elasticity
	joint.dampingRatio = 1.0f; // How quickly vibrations fade away (<=1.0)
	
	joint.bodyA = this->mB2Body;
	joint.bodyB = bodyB->mB2Body;
	
	// Warning: Fixtures and joints are attached relative to the body's (not world's) origin! 
	joint.localAnchorA.Set(offsetX, offsetY);
	joint.localAnchorB.Set(offsetBX, offsetBY);
	
	p1 = joint.bodyA->GetWorldPoint(joint.localAnchorA);
	p2 = joint.bodyB->GetWorldPoint(joint.localAnchorB);
	d = p2 - p1;
	joint.length = d.Length();
	World::get()->CreateJoint(&joint); // Store the joint reference if needed
}

void BodyBox2d::removeJoint()
{
	if (mJoint)
	{
		World::get()->DestroyJoint(mJoint);
		mJoint = 0;
	}
}

void BodyBox2d::checkAlive()
{
	if (mHealth < 30.0f)
		removeJoint();
}

void BodyBox2d::createRevoluteJoint(GLfloat localX, GLfloat localY, BodyBox2d * bodyB, GLfloat localBX, GLfloat localBY)
{
	b2RevoluteJointDef joint;
	joint.bodyA = this->mB2Body;
	joint.bodyB = bodyB->mB2Body;
	
	joint.localAnchorA.Set(localX, localY); // Relative to body's origin
	joint.localAnchorB.Set(localBX, localBY);
	
	joint.lowerAngle = -M_PI/180.0f * mJointLimit; // Adjust angle for according to damage
	joint.upperAngle = M_PI/180.0f * mJointLimit;
	joint.enableLimit = true;
	
//	j.enableMotor = true;
//	j.motorSpeed = 70.0f;
//	j.maxMotorTorque = 50.0f;
	joint.collideConnected = false;
	
	bodyB->mJoint = (b2RevoluteJoint *)World::get()->CreateJoint(&joint); // Store the joint reference if needed
}

// This method requires VERTEX_ATTRIBS array to be active
BodyBox2d & BodyBox2d::ddraw(bool addOwnPos, bool drawJoint)
{
	ShaderManager::get()->useProgram(eShaderBasic); // Use basic shader for debug draw
	
	GLfloat * lst = 0;
	int count;
	for (const b2Fixture * i = mB2Body->GetFixtureList(); i; i = i->GetNext())
	{
        switch (i->GetType()) {
            case b2Shape::e_circle:
                // ddraw is NOT a polygon shape
                continue;
            case b2Shape::e_loop:
            {
                b2LoopShape & shape = *((b2LoopShape *)i->GetShape());
                lst = new GLfloat[(count = shape.GetCount()) * 2];
                for (int j = 0; j < shape.GetCount(); j++)
                {
                    b2Vec2 vec = shape.GetVertex(j);
                    lst[j * 2] = vec.x;
                    lst[j * 2 + 1] = vec.y;
                }
            }
            break;

            case b2Shape::e_polygon:
            {
                b2PolygonShape & shape = *((b2PolygonShape *)i->GetShape());
                lst = new GLfloat[(count = shape.GetVertexCount()) * 2];
                for (int j = 0; j < shape.GetVertexCount(); j++)
                {
                    b2Vec2 vec = shape.GetVertex(j);
                    lst[j * 2] = vec.x;
                    lst[j * 2 + 1] = vec.y;
                }
            }
            break;

            default:
                implementMe();
        }
		MatrixManager::get()->pushMatrix();
		if (addOwnPos) { MatrixManager::get()->translate(posX(), posY(), 0.0f); MatrixManager::get()->rotate(angle(), 0.0f, 0.0f, 1.0f); }
		
		glUniformMatrix4fv(ShaderManager::get()->program()->uniforms[uniMatrixProjModelView], 1, GL_FALSE, MatrixManager::get()->matrixProjModelView());
		glUniform4f(ShaderManager::get()->program()->uniforms[uniLightColor], 1.0f, 1.0f, 1.0f, 1.0f);
		
		glDisableVertexAttribArray(NORMAL_ARRAY);
		glDisableVertexAttribArray(TEXCOORD_ARRAY);
		glVertexAttribPointer(VERTEX_ARRAY, 2, GL_FLOAT, 0, 0, lst);

		glDrawArrays(GL_LINE_LOOP, 0, count);
		glEnableVertexAttribArray(NORMAL_ARRAY);
		glEnableVertexAttribArray(TEXCOORD_ARRAY);
		
		MatrixManager::get()->popMatrix();
		delete [] lst;
	}
	
	if (drawJoint)
	{
		MatrixManager::get()->pushMatrix();
		GLfloat v[] = { 0.0f, 0.0f, 0.0f, 0.0f };
		b2Joint * j = mB2Body->GetJointList()->joint; // Deal with the 1st one only
		v[0] = j->GetAnchorA().x; v[1] = j->GetAnchorA().y;
		v[2] = j->GetAnchorB().x; v[3] = j->GetAnchorB().y;
		//NSLog(@"%f %f %f %f", v[0],v[1],v[2],v[3]);
		glUniformMatrix4fv(ShaderManager::get()->program()->uniforms[uniMatrixProjModelView], 1, GL_FALSE, MatrixManager::get()->matrixProjModelView());
		glVertexAttribPointer(VERTEX_ARRAY, 2, GL_FLOAT, 0, 0, v);
		glDrawArrays(GL_LINES, 0, 2);
		MatrixManager::get()->popMatrix();
	}
	
	return * this;
}

void BodyBox2d::shouldDie()
{
	if (posX() < -kSceneWidth/2.0f)
	{
		printf("Deleting body!\n");

		if (_isOn) mB2Body->SetActive(false);
		_isOn = false;
//		delete this; // Oh boy
	}
}
