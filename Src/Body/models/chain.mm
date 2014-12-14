//
//  chain.cpp
//  Kamikaze
//
//  Created by Anton Tropashko on 22.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "chain.h"

Chain::Chain(GLfloat halfWidth, GLfloat halfHeight, int segments,
               GLfloat posX, GLfloat posY, GLfloat density)
{
    m_segcount = segments;
    assert(m_segcount>0); // 1 segment minimum
	assert(m_segcount<=MAXSEGMENTS); // 30 segments maximum

    GLfloat seghheight = halfHeight / m_segcount;
	//GLfloat step = seghheight;
    for(byte s=0;s< m_segcount;++s) {
        m_segments[s]= new BodyBox2d(eBodyTypeDynamic, eBodyShapeBox,
                                     halfWidth, seghheight, posX, posY, density);
        //posY -= step;
        NSLog(@"%f %f", posX, posY);
        if(s>0) {
			//GLfloat pivotX=halfWidth/2.f;
            m_segments[s]->createRevoluteJoint(
							0.f, .4f,
							m_segments[s-1],
							0.f, -.39f );
            m_segments[s-1]->adjJointLimit(180);
        }
        m_segments[s]->addMesh("chain").
            addTexture("chain_color.pvr").
            addTexture("chain_nm.pvr");
    }
}

void
Chain::draw(bool addOwnPos, bool drawJoint)
{
    assert(m_segcount>0);
    for(int s=0;s< m_segcount;++s) {
        m_segments[s]->push().place().spinZ().draw(addOwnPos).pop();
        //m_segments[s]->push().ddraw(addOwnPos, drawJoint).pop();
    }
}

BodyBox2d *
Chain::first() const
{
    assert(m_segcount>0);
    return m_segments[0];
}

BodyBox2d *
Chain::last() const
{
    assert(m_segcount>0);
    return m_segments[m_segcount-1];
}
