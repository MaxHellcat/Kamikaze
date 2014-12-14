//
//  ActionRenderer.h
//  Kamikaze
//
//  Created by Max Reshetey on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef ACTION_RENDERER_H
#define ACTION_RENDERER_H

#include "Renderer.h"

#include <OpenGLES/ES2/gl.h>
//#include <OpenGLES/ES2/glext.h>

#include "Box2D/Box2D.h" // Box2D physics engine (include here as we're inheriting b2ContactListener)

#include "Shader.h"

#include "ParticleHolder.h"

#include "Singleton.h"

#include "BodyBox2d.h"
#include "BodySimple.h"

#include "chain.h"

class LevelFactory;


// TODO: You can implement a b2DestructionListener that allows b2World to inform you when a shape
// or joint is implicitly destroyed because an associated body was destroyed.
// This will help prevent your code from accessing orphaned pointers.
class ActionRenderer : public Renderer, public b2ContactListener
{
public:
	ActionRenderer();
	virtual ~ActionRenderer();

	virtual void frame();

	void drawBack();
	
	
	void beat();

private: // Methods
	virtual void touchesBegan(float touchX, float touchY);
	virtual void touchesMoved(float touchX, float touchY);
	virtual void touchesEnded(float touchX, float touchY);
	virtual void accel(float x, float y, float z);
	
	void BeginContact(b2Contact * contact);

	void drawWidgets();
	void setHPColor(float health);
	void drawPool();
	void drawTime();
	void drawScore();
	void drawMenuPause();
	void drawMenuCompletion();
	void levelCompleted();

private: // Variables
	enum { eBackLeft=0, eBackRight, eNumBackParts };
	BodySimple _back[eNumBackParts];
	int bgTexCounter; // Counter of background textures (used for proper bg parts ordering)

	float _speed; // Airplane flight speed, meters / sec
	float _speedPerFrame;
	int _score;
	float _metersGone; // Meters flown

	LevelFactory * _levelFactory;
	Airplane * _jet; // All parts are incapsulated

	BodyBox2d * _ground;

	Widget _menuPause, _menuEnd;

	BodyBox2d * _basket;
    Chain * _chain;
#define MAXNESTLINGS 5
    BodyBox2d *m_nestlings[MAXNESTLINGS];
//	float _touchY;

//	FogHolder emitter; // Smoke behind the jet, disabled till works perfectly

	// Widgets
	enum { eJoystickHeight=0, eJoystickSlider, eNumJoystickParts };
	Widget _joystick[eNumJoystickParts];
	Widget _pauseButton;

	enum { eFireButtonSpinLayer, eFireButtonBaseLayer, eNumFireButtonLayers };
	Widget _fireButton[eNumFireButtonLayers];

	enum { eHPButton=0, eHPFuselage, eHPPropeller, eHPWings, eHPTail, eHPFrame, eNumHPParts };
	BodySimple _hp[eNumHPParts];

	enum { eSpeedometer=0, eSpeedometerArrow, eNumSpeedometerParts };
	BodySimple _speedometer[eNumSpeedometerParts];

	enum { eLegendScore=0, eLegendHighscore, eNumLegends };
	BodySimple _legend[eNumLegends];
    
};
const BOOL payloadMission=YES;

#endif // #ifndef ACTION_RENDERER_H
