/*
 *  chain.h
 *  Kamikaze
 *
 *  Created by Arkadiev on 12.07.11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */


#import "BodyBox2d.h"

const int MAXSEGMENTS=30;
class Chain
{
	//friend class ActionRenderer;
    Chain(const Chain&) { implementMe(); }
    
    BodyBox2d *m_segments[MAXSEGMENTS];
    int m_segcount;
public:
    BodyBox2d *first() const, *last() const;
    // eBodyTypeDynamic, eBodyShapeBox, 0.2f, 1.5f, 0.0f, -2.0f

    Chain(GLfloat halfWidth, GLfloat halfHeight, int segments,
           GLfloat posX, GLfloat posY, GLfloat density=.99);
    
    void draw(bool addOwnPos = true, bool drawJoint = false);
};
