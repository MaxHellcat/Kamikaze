//
//  Render.h
//  Kamikaze
//
//  Created by Max Reshetey on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef RENDERER_H
#define RENDERER_H

#include "Timer.h" // FPS counter

#include "iostream" // For time, printf

#include "Shader.h"

#include "PowerVRTools/PVRTFixedPoint.h" // For text print
#include "PowerVRTools/PVRTPrint3D.h" // For text print

@class _Widget;

// Basic abstract class for all renderers
class Renderer
{
protected:
	Renderer(); // Only kids can create

private: // Methods
	Renderer(const Renderer & rhs); // Never copy
	Renderer & operator=(const Renderer & rhs); // Never assign

	void drawFPS();

public: // Methods
	virtual ~Renderer(); // Dont place in protected!

	void preframe(); // Relevant operations prior to frame draw
	virtual void frame() = 0; // Kids must define this
	virtual void touchesBegan(float touchX, float touchY) {};
	virtual void touchesMoved(float touchX, float touchY) {};
	virtual void touchesEnded(float touchX, float touchY) {};
	virtual void accel(float x, float y, float z) {};

	virtual void beat() = 0; // Timer 
	virtual void eventHertzOne() {};

	// For default touch, currently touching root view
	// Called when no any specific sub-views touched (as each must have own callback)
//	virtual void touchDefault() {};

protected: // Methods
	void setLightColor(GLfloat r=1.0f, GLfloat g=1.0f, GLfloat b=1.0f, GLfloat a=1.0f) { glUniform4f(ShaderManager::get()->program()->uniforms[uniLightColor], r, g, b, a); }
	void setLightPos(GLfloat x=0.0f, GLfloat y=0.0f, GLfloat z=100.0f) { glUniform3f(ShaderManager::get()->program()->uniforms[uniLightPos], x, y, z); }
	void drawGrid(); // Aux method to draw a grid with step 1 meter

	float randomFloat(float lo, float hi);

protected: // Variables
	float _screenWidth, _screenHeight; // Screen size in pixels

	uint _frames; // Frame counter

	CFAbsoluteTime _renderStarted; // TODO: Maybe not needed here

	Timer timer; // FPS counter
	CPVRTPrint3D printer;
};

#endif // RENDERER_H
