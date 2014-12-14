//
//  nestling.h
//  Kamikaze
//
//  Created by Anton Tropashko on 22.08.11.
//  Copyright 2011 InfoTechnology. All rights reserved.
//

#import "BodyBox2d.h"

class Nestling : public BodyBox2d
{
public:
    Nestling(float halfWidth, float halfHeight, float posX, float posY,
             float density=0.2f);
};
