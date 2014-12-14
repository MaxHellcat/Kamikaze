//
//  nestling.cpp
//  Kamikaze
//
//  Created by Anton Tropashko on 22.08.11.
//  Copyright 2011 InfoTechnology. All rights reserved.
//

#include "nestling.h"

Nestling::Nestling(GLfloat halfWidth, GLfloat halfHeight,
             GLfloat posX, GLfloat posY, GLfloat density)
: BodyBox2d(eBodyTypeDynamic, eBodyShapeCircle, halfWidth, halfHeight, posX, posY,
            density, .0f)
{
	if(random()%2) {
		addMesh("Ball").
		addTexture("cone_color_1").
		addTexture("ball_nm");
	}else{
		//addMesh("Ball").
		addMesh("Cone").
		addTexture("cone_color_2").
		addTexture("cone_nm");
	}
}
