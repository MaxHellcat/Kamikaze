//
//  scarf.h
//  Kamikaze
//
//  Created by Anton Tropashko (Arkadiev really) sometime in 11.
//  Copyright 2011 InfoTech. All rights reserved.
//

#ifndef CHAIN_H
#define CHAIN_H

#include "BodyBox2d.h"
#include "Singleton.h"

#include <vector>

using namespace std;

class _Scarf;

typedef Singleton<_Scarf> Scarf;

class _Scarf
{
	vector<BodyBox2d *> chain;
	
	float x, y;
	
public:
	
	void init(BodyBox2d * master);
	
	void draw();
	
	~_Scarf();
    /*	
     void init(float x, float y)
     {
     // Ground init
     b2Body* ground = NULL;
     {
     b2BodyDef bd;
     ground = World::get()->CreateBody(&bd);
     
     b2PolygonShape shape;
     shape.SetAsBox(1, 1);
     ground->CreateFixture(&shape, 0.0f);
     }
     
     {
     // ring template
     b2PolygonShape shape;
     shape.SetAsBox(0.6f, 0.125f);
     
     b2FixtureDef fd;
     fd.shape = &shape;
     fd.density = 20.0f;
     fd.friction = 0.2f;
     
     // joint template
     b2RevoluteJointDef jd;
     jd.collideConnected = false;
     
     // chain start
     b2Body* prevBody = ground;
     
     chain.push_back(ground);
     
     for (int32 i = 0; i < 30; ++i)
     {
     // locate next part
     b2BodyDef bd;
     bd.type = b2_dynamicBody;
     bd.position.Set(x + i, y);
     
     // create next part
     b2Body* body = World::get()->CreateBody(&bd);
     body->CreateFixture(&fd);
     
     // wtf is that?
     b2Vec2 anchor(float32(i), y);
     
     // init chain connection
     jd.Initialize(prevBody, body, anchor);
     World::get()->CreateJoint(&jd);
     
     chain.push_back(body);
     
     // loop
     prevBody = body;
     }
     }
     }
     
     void ddraw()
     {
     ShaderManager::get()->useProgram(eShaderBasic); // Use basic shader for debug draw
     
     GLfloat * lst = 0;
     int count;
     for (vector<b2Body *>::iterator i = chain.begin(); i != chain.end(); i++)
     {
     b2PolygonShape & shape = *((b2PolygonShape *)(((*i)->GetFixtureList())->GetShape()));
     
     lst = new GLfloat[(count = shape.GetVertexCount()) * 2];
     
     for (int j = 0; j < shape.GetVertexCount(); j++)
     {
     b2Vec2 vec = shape.GetVertex(j);
     lst[j * 2] = vec.x + (*i)->GetPosition().x;
     lst[j * 2 + 1] = vec.y + (*i)->GetPosition().y;
     }
     
     MatrixManager::get()->pushMatrix();
     
     //if (addOwnPos) { MatrixManager::get()->translate(x, y, 0.0f); } //MatrixManager::get()->rotate(angle(), 0.0f, 0.0f, 1.0f); }
     
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
     }*/
};

#endif
