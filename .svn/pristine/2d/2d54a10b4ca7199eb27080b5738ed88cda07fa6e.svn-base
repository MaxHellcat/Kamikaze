//
//  basket.cpp
//  Kamikaze
//
//  Created by Anton Tropashko on 22.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "basket.h"

Basket::Basket(GLfloat halfWidth, GLfloat halfHeight,
               GLfloat posX, GLfloat posY, GLfloat density)
    : BodyBox2d(halfWidth, halfHeight, posX, posY, density)
{
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(posX, posY);
	mB2Body = World::get()->CreateBody(&bodyDef);
    
	mB2Body->SetUserData(this); // Remember reference to us
    
	b2FixtureDef fixtureDef;
	b2PolygonShape box;
    
    const GLfloat yoff=.1f;
	const GLfloat xoff=.38f;
	// You must create polygons with a counter clockwise winding (CCW)
	b2Vec2 vec[] =
	{
		b2Vec2(-halfWidth, 0.f), // Start with left
		b2Vec2(-halfWidth+xoff, -halfHeight),
		b2Vec2(-halfWidth+xoff, -halfHeight+yoff),
	};
	box.Set(vec, 3);
	fixtureDef.shape = &box;
	
	fixtureDef.density = density; // Kg/m2
	fixtureDef.friction = 0.8f;
	fixtureDef.restitution = .1f; // Body elasticity
	mB2Body->CreateFixture(&fixtureDef);

    b2Vec2 vec2[] =
	{
		b2Vec2(halfWidth, 0.f), // Start with left
		b2Vec2(halfWidth-xoff, -halfHeight+yoff),
		b2Vec2(halfWidth-xoff, -halfHeight),
	};
    b2PolygonShape box2;
	box2.Set(vec2, 3);
	fixtureDef.shape = &box2;
    // just for fun weigh down left or right side of the basket
    // consider as a handicap for advanced payload levels
	//fixtureDef.density = density*1.9f; // Kg/m2
	mB2Body->CreateFixture(&fixtureDef);

	b2Vec2 vec3[] =
	{
		b2Vec2(-halfWidth+xoff, -halfHeight),
		b2Vec2(halfWidth-xoff, -halfHeight),
		b2Vec2(halfWidth-xoff, -halfHeight+yoff),
	};
    b2PolygonShape box3;
	box3.Set(vec3, 3);
	fixtureDef.shape = &box3;
    // just for fun weigh down left or right side of the basket
    // consider as a handicap for advanced payload levels
	//fixtureDef.density = density*1.9f; // Kg/m2
	mB2Body->CreateFixture(&fixtureDef);

    _shape = eBodyShapeComplex;
}
