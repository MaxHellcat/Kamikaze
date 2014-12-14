//
//  Airplane.mm
//  Kamikaze
//
//  Created by Max Reshetey on 6/15/11.
//  Copyright 2011 InfoTechnologies. All rights reserved.
//
#include "BodyBox2d.h"

#include "PlayerCareer.h" // Current upgrades

#include "scarf.h"

#include "chain.h"

Airplane::~Airplane()
{
	// Release attached parts
	for (byte i = 0; i < eNumJetParts; ++i)
	{
		delete _parts[i]; _parts[i] = 0;
	}
	
	// Release holders
	for (byte i = 0; i < eNumJetHolders; ++i)
	{
		delete _holders[i]; _holders[i] = 0;
	}
}

Airplane::Airplane(float halfWidth, float halfHeight, float posX, float posY, float density) :
BodyBox2d(halfWidth, halfHeight, posX, posY)
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(posX, posY);
	mB2Body = World::get()->CreateBody(&bodyDef);
    
	mB2Body->SetUserData(this); // Remember reference to us
    
	b2FixtureDef fixtureDef;
	b2PolygonShape box;
    
	// You must create polygons with a counter clockwise winding (CCW)
	b2Vec2 vec[] = // Fuselage
	{
		b2Vec2(-halfWidth, -halfHeight+0.7f), // Start with bottom-left A
		b2Vec2(0.0f, -halfHeight),
		b2Vec2(halfWidth, -halfHeight-0.1f),
		b2Vec2(halfWidth, halfHeight+0.1f),
		b2Vec2(-halfWidth, halfHeight),
	};
	box.Set(vec, 5);
	fixtureDef.shape = &box;
	
	fixtureDef.density = density; // Kg/m2
	fixtureDef.friction = 0.8f;
	fixtureDef.restitution = 0.5f; // Body elasticity
	mB2Body->CreateFixture(&fixtureDef);
	
	// Back chassis
	vec[0] = b2Vec2(-2.0f, 0.0f);
	vec[1] = b2Vec2(-1.6f, -0.5f);
	vec[2] = b2Vec2(-1.2f, 0.0f),
	box.Set(vec, 3);
	fixtureDef.shape = &box;
	mB2Body->CreateFixture(&fixtureDef);
	
	// Airplane's invisible holders and their joints, Z-traverse:
	// C D
	// A B
	float offsetX = 1.7f, offsetY = 0.0f;
	float halfX = 8.5f, halfY = 20.0f;
	_holders[A] = new BodyBox2d(eBodyTypeStatic, eBodyShapeBox, 0.5f, 0.5f, -halfX+posX+offsetX, -halfY+posY+offsetY); // Left pair
	_holders[C] = new BodyBox2d(eBodyTypeStatic, eBodyShapeBox, 0.5f, 0.5f, -halfX+posX+offsetX, halfY+posY+offsetY);
	_holders[B] = new BodyBox2d(eBodyTypeStatic, eBodyShapeBox, 0.5f, 0.5f, halfX+posX+offsetX, -halfY+posY+offsetY); // Right pair
	_holders[D] = new BodyBox2d(eBodyTypeStatic, eBodyShapeBox, 0.5f, 0.5f, halfX+posX+offsetX, halfY+posY+offsetY);
	
	// Joints, first coords are relative to the body's origin
	createDistanceJoint(-1.5f+offsetX, -1.0f, _holders[A]); // Left pair
	createDistanceJoint(-1.5f+offsetX, 1.0f, _holders[C]);
	createDistanceJoint(1.5f+offsetX, -1.0f, _holders[B]); // Right pair
	createDistanceJoint(1.5f+offsetX, 1.0f, _holders[D]);
    
	_shape = eBodyShapeAirplane;
    
	// Attach remaining parts
	UpgradeItem * item = PlayerCareer::get()->current(eUpgradeWings);
    
	// Wings and chassis
	GLfloat shapeWing[][XY] = // CCW traverse, starting with bottom-left A
	{
		{-0.8f, -0.1f}, // A
		{0.4f, -0.8f},
		{0.8f, -0.1f}
	};
	_parts[eJetWings] = new BodyBox2d(shapeWing, 3, posX, posY, density);
	_parts[eJetWings]->addMesh(item->mesh.c_str()).
	addTexture(item->texDiffuse.c_str()).
	addTexture(item->texNormal.c_str()).
	addTexture("bloored-light-reflection-map");
	createRevoluteJoint(1.0f, -0.3f, _parts[eJetWings]); // Attach it to the fuselage
    
	// Tail
	GLfloat shapeKeel[][XY] = // CCW traverse, starting with bottom-left A
	{
		{-0.5f, 0.0f}, // A
		{0.5f, 0.0f},
		{0.0f, 0.5f}
	};
	_parts[eJetTail] = new BodyBox2d(shapeKeel, 3, posX, posY, density);
	_parts[eJetTail]->addMesh(item->meshExtra.c_str()).
	addTexture(item->texDiffuse.c_str()).
	addTexture(item->texNormal.c_str()).
	addTexture("bloored-light-reflection-map");
	createRevoluteJoint(-halfWidth+0.7f, 0.5f, _parts[eJetTail]); // Attach it to the fuselage
	
	Scarf::alloc();
	Scarf::get()->init(_parts[eJetTail]);
	
	// Propeller
	item = PlayerCareer::get()->current(eUpgradePropeller);
	GLfloat shapePropeller[][XY] = // CCW traverse, starting with bottom-left A
	{
		{-0.1f, -0.9f}, // A
		{0.2f, 0.0f},
		{-0.1f, 0.9f}
	};
	_parts[eJetPropeller] = new BodyBox2d(shapePropeller, 3, posX+halfWidth, posY, density);
	_parts[eJetPropeller]->addMesh(item->mesh.c_str()).addTexture(item->texDiffuse.c_str());
	createRevoluteJoint(halfWidth+0.2f, 0.0f, _parts[eJetPropeller]); // Attach it to the fuselage
    
	/*
	 GLfloat shapePilot[][XY] = // CCW traverse, starting with bottom-left A
	 {
	 {-0.1f, -0.1f}, // A
	 {0.1f, -0.1f},
	 {0.1f, 0.1f},
	 {-0.1f, 0.1f}
	 };
	 _parts[eJetPilot] = new BodyBox2d(shapePilot, 4, posX, posY);
	 _parts[eJetPilot]->addMesh("pilot").
	 addTexture("pilot_diffuse").addTexture("pilot_normal").addTexture("bloored-light-reflection-map");;
	 createRevoluteJoint(0.0f, 0.0f, _parts[eJetPilot]); // Attach it to the fuselage
	 /*
	 // Gun
	 GLfloat shapeGun[][XY] = // CCW traverse, starting with bottom-left A
	 {
	 {-0.5f, -0.3f}, // A
	 {0.5f, -0.3f},
	 {0.5f, 0.3f},
	 {-0.5f, 0.3f}
	 };
	 _parts[eJetGun] = new BodyBox2d(shapeGun, 4, posX, posY);
	 _parts[eJetGun]->addMesh("tomato_gun").addTexture("gun_diffuse").
	 addTexture("gun_normal_map").addTexture("bloored-light-reflection-map");
	 createRevoluteJoint(1.4f, 0.7f, _parts[eJetGun]); // Attach it to the fuselage
     
	 */
}

// TODO: Pass through the flight speed from the action, to vary propeller speed
Airplane & Airplane::draw(bool addOwnPos, GLfloat adjX, GLfloat adjY, GLfloat adjZ)
{
	static GLfloat prevVelocity = 0.0f;
	GLfloat shiftVelocity = velocity().y;
	prevVelocity = shiftVelocity = (fabsf_neon_hfp(shiftVelocity - prevVelocity) > 3.0f)?
	((shiftVelocity>prevVelocity)?prevVelocity+3.0f:prevVelocity-3.0f):shiftVelocity;
    
	static float rot = 0.0f; // For jet X waving
	static float waveAngle = 0.0f;
	waveAngle = -shiftVelocity * 2.0f - sinf(rot+=0.05f)*PVRT_MAX(0.0f, 20.0f - fabsf_neon_hfp(shiftVelocity) / 2.0f);
    
	ShaderManager::get()->useProgram(eShaderNormalReflectMapping);
    
	// TODO: You really don't need to do this each frame, on the same shader
	glUniform4f(ShaderManager::get()->program()->uniforms[uniLightColor], 1.0f, 1.0f, 1.0f, 1.0f);
	glUniform3f(ShaderManager::get()->program()->uniforms[uniLightPos], 1.0f, 1.0f, 100.0f);
    
	push();
    
    //	static float r = 0.0f; r += 0.1f;
    //	MatrixManager::get()->rotate(r, 1.0f, 1.0f, 1.0f);
    
	// Fuselage
	push().
	place().
	spinZ().
	spinX(false, waveAngle);
	Body::draw(false, adjX, adjY, adjZ);
	pop();
    
	// Tail
	_parts[Airplane::eJetTail]->push().
	place().spinZ().place(false, 1.8f, -0.5f).spinX(false, waveAngle).
	draw(false).
	pop();
    
	// Wings
	_parts[Airplane::eJetWings]->push().
	place().spinZ().place(false, -1.0f, 0.3f).spinX(false, waveAngle).
	draw(false).
	pop();
	
	// Propeller
    //	ShaderManager::get()->useProgram(eShaderLightingPositional);
    //	glUniform4f(ShaderManager::get()->program()->uniforms[uniLightColor], 1.0f, 1.0f, 1.0f, 1.0f);
    //	glUniform3f(ShaderManager::get()->program()->uniforms[uniLightPos], 1.0f, 1.0f, 1.0f);
	
    //	setLightColor();
    //	setLightPos();
	_parts[Airplane::eJetPropeller]->push().place().spinZ().place(false, -2.7f);
    //	rotate(waveAngle, 1.0f, 0.0f, 0.0f); // Wing waving - decreased at shift
    //	_parts[Airplane::eJetPropeller]->spinX(false, 8.0f+_speed, true).draw(false).pop();
	_parts[Airplane::eJetPropeller]->spinX(false, 8.0f, true).draw(false).pop();
	
	// Check if we need to drop parts
    //	(*_jet)[Airplane::eJetPropeller]->checkAlive();
    //	(*_jet)[Airplane::eJetTail]->checkAlive();
    //	(*_jet)[Airplane::eJetWings]->checkAlive();
    
	pop();
	
	return * this;
}

Airplane & Airplane::ddraw(bool addOwnPos, bool drawJoint)
{
	ShaderManager::get()->useProgram(eShaderBasic); // Use basic shader for debug draw
	
	GLfloat * lst = 0;
	int count;
	for (const b2Fixture * i = mB2Body->GetFixtureList(); i; i = i->GetNext())
	{
		b2PolygonShape & shape = *((b2PolygonShape *)i->GetShape());
		lst = new GLfloat[(count = shape.GetVertexCount()) * 2];
		for (int j = 0; j < shape.GetVertexCount(); j++)
		{
			b2Vec2 vec = shape.GetVertex(j);
			lst[j * 2] = vec.x;
			lst[j * 2 + 1] = vec.y;
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
	
	// Attached parts and holders
	for (GLbyte i=0; i<eNumJetParts; ++i) _parts[i]->push().ddraw().pop();
	
	_holders[Airplane::A]->ddraw(true, true);
	_holders[Airplane::B]->ddraw(true, true);
	_holders[Airplane::C]->ddraw(true, true);
	_holders[Airplane::D]->ddraw(true, true);
	
	return * this;
}

Airplane & Airplane::setPosX(float posX)
{
	_holders[A]->setPosX(posX);
	_holders[B]->setPosX(posX);
	_holders[C]->setPosX(posX);
	_holders[D]->setPosX(posX);
	
	return * this;
}

Airplane & Airplane::setPosY(float posy)
{
	_holders[A]->setPosY(posy);
	_holders[B]->setPosY(posy);
	_holders[C]->setPosY(posy);
	_holders[D]->setPosY(posy);
	
	return * this;
}

void Airplane::force(float forceX)
{
	mB2Body->ApplyForce(b2Vec2(forceX, 0.0f), mB2Body->GetWorldCenter());
}
