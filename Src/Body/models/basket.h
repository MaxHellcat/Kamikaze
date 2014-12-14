//
//  basket.h
//  Kamikaze
//
//  Created by Anton Tropashko on 22.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BodyBox2d.h"

class Basket : public BodyBox2d
{
	friend class ActionRenderer;
    Basket(const Basket&) { implementMe(); }
    
public:
    Basket(GLfloat halfWidth, GLfloat halfHeight,
           GLfloat posX, GLfloat posY, GLfloat density);
    /*
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
     */
};
