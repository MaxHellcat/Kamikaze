//
//  MainMenuRenderer.h
//  Kamikaze
//
//  Created by Max Reshetey on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef MAINMENU_RENDERER_H
#define MAINMENU_RENDERER_H

#include "Renderer.h"

//#include "BodyBox2d.h"
#include "BodySimple.h"

//#include <string>
//#include <vector>

//#include "PlayerCareerDefs.h" // For UpgradeType enum


// Class responsible for drawing Main menu and handling touch events
// Also draws splash screen
class MainMenuRenderer : public Renderer
{
public:
	MainMenuRenderer();
	virtual ~MainMenuRenderer();

	virtual void frame();

	// TODO: Move this into ShaderManager
	void setLightColor(GLfloat r=1.0f, GLfloat g=1.0f, GLfloat b=1.0f, GLfloat a=1.0f) { glUniform4f(ShaderManager::get()->program()->uniforms[uniLightColor], r, g, b, a); }
	void setLightPos(GLfloat x=0.0f, GLfloat y=0.0f, GLfloat z=100.0f) { glUniform3f(ShaderManager::get()->program()->uniforms[uniLightPos], x, y, z); }

private: // Methods
	virtual void touchesBegan(float touchX, float touchY);
	virtual void touchesEnded(float touchX, float touchY);
	
	virtual void beat() {};
	virtual void eventHertzOne();

private: // Variables
	enum { eSplashBack, eSplashLoadLine, eSplashPilot, eNumSplashItems };
	BodySimple _splash[eNumSplashItems], _planeSmall;

	Widget _back, _handle, _plane;

	enum { eCloud1, eCloud2, eCloud3, eNumClouds };
	Widget _clouds[eNumClouds];

	enum { eFlash1, eFlash2, eNumFlashes };
	Widget _flashes[eNumClouds];
};

#endif
