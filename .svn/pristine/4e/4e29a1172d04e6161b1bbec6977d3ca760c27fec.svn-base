//
//  scarf.cpp
//  Kamikaze
//
//  Created by Anton Tropashko on 22.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "scarf.h"

void _Scarf::init(BodyBox2d * master)
{
    BodyBox2d * prev = master;
    
    float offset = 8;
    
    for (int i = 0; i < 10; i++)
    {
        BodyBox2d * patch = new BodyBox2d(eBodyTypeDynamic, eBodyShapeBox, 0.1, 0.1, 0, 0, 0.01);
        patch
        ->addMesh()
        .addTexture("brick.pvr");
        
        patch->createRevoluteJoint(0.1, 0, prev, -offset, 0);
        
        offset = 0.1;
        
        prev = patch;
        
        chain.push_back(patch);
    }
}

void _Scarf::draw() 
{
    for (vector<BodyBox2d *>::iterator i = chain.begin(); i != chain.end(); i++)
    {
        (*i)->push().draw().pop();
    }
}

_Scarf::~_Scarf()
{
    for (vector<BodyBox2d *>::iterator i = chain.begin(); i != chain.end(); i++)
        delete *i;
}
