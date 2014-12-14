//
//  Render.cpp
//  Kamikaze
//
//  Created by Max Reshetey on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Renderer.h"

#include "constants.h"

#include "Matrix.h"


Renderer::Renderer() :
_screenWidth(0.0f),
_screenHeight(0.0f),
_frames(0),
_renderStarted(0.0),
timer()
{
	//
	// Init OpenGL ES states (http://www.khronos.org/opengles/sdk/docs/man/)
	//

//	glEnable(GL_BLEND); // Blending is initially disabled, enable on demand
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glEnable(GL_CULL_FACE); // Facet culling is initially disabled, enable it
	glCullFace(GL_BACK); // The initial value is GL_BACK
	glFrontFace(GL_CCW); // By default, counterclockwise polygons are taken to be front-facing

	// PowerVR: We are using a projection matrix optimized for a floating point depth buffer,
	// so the depth test and clear value need to be inverted (1 becomes near, 0 becomes far)
	glEnable(GL_DEPTH_TEST); // Initially disabled, enable it
//	glClearDepthf(1.0f); // The initial value is 1
	// Invert z-depth, see PowerVR SGX ES 2.0 recommendations
	glDepthRangef(1, 0); // The initial value is 0, 1
	// Since range inverted, change the depth func, see PowerVR SGX ES 2.0 recommendations
//	glDepthFunc(GL_GEQUAL); // The initial value is GL_LESS

//	glEnable(GL_DITHER); // If enabled, dither color components or indices before they are written to the color buffer

//	glEnable(GL_POLYGON_OFFSET_FILL); // If enabled, an offset is added to depth values of a polygon's fragments produced by rasterization
//	glPolygonOffset(factor, units);  The initial value is 0, 0

//	glEnable(GL_SAMPLE_ALPHA_TO_COVERAGE);
//	glEnable(GL_SAMPLE_COVERAGE);
//	glSampleCoverage(value, invert); // The initial value is 1.0, GL_FALSE

//	When the scissor test is disabled, it is as though the scissor box includes the entire window
//	glEnable(GL_SCISSOR_TEST); // The test is initially disabled
//	glScissor(0, 0, (GLsizei)_width, (GLsizei)_height);

//	glEnable(GL_STENCIL_TEST); // Initially disabled

	glClearColor(0.3f, 0.3f, 0.3f, 1.0f); // Not so bright

	// Init app states
	_renderStarted = CFAbsoluteTimeGetCurrent(); // Remember renderer start time

	// Init the random number generator
	srand((GLuint)time(0));

	// Setup text printing
	printer.SetTextures(NULL, 1.5f, 2.0f);
}

Renderer::~Renderer() {}

void Renderer::preframe()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// Reset matrices
	MatrixManager::get()->matrixMode(MatrixManager::eProjectionMatrix);
	MatrixManager::get()->loadIdentity();
	MatrixManager::get()->matrixMode(MatrixManager::eModelViewMatrix);
	MatrixManager::get()->loadIdentity();

	// Setup isometric matrix, a 20m cube (yes, after ~8 months we still can't set up projective matrix)
	MatrixManager::get()->ortho(-kSceneWidth/2.0f, kSceneWidth/2.0f, -kSceneWidth/2.0f, kSceneWidth/2.0f, kSceneWidth/2.0f, -kSceneWidth/2.0f);

//	drawGrid();
	drawFPS();

}

inline
void Renderer::drawFPS()
{
	static char buf[10];
	sprintf(buf, "%2.1f", timer.fps(++_frames));
	printer.Print3D(-kSceneWidth/2.0f+0.3f, kSceneHeight/2.0f-0.5f, 1.0f, 0xFFFFFFFF, buf); // Score
//	printer.Flush(); // Kids must call flush eventually

//	if (_frames % 20 == 0) printf("Frame %d, took: %3.2fms, fps: %3.2f\n", _frames-1, 0.0f, timer.fps(_frames-1));
}

float Renderer::randomFloat(float lo, float hi)
{
	float r = (float)(rand() & (RAND_LIMIT));
	r /= RAND_LIMIT;
	r = (hi - lo) * r + lo;
	return r;
}

// For debugging
GLvoid Renderer::drawGrid()
{
	static const GLfloat v[] = { -10.0f, 0.0f, 10.0f, 0.0f }; // Line coords

	// Horizontal grid
	MatrixManager::get()->pushMatrix();
	MatrixManager::get()->translate(0.0f, -8.0f, 0.0f);

	ShaderManager::get()->useProgram(eShaderBasic);

	for (GLbyte i = 0; i < 15; i++)
	{
		MatrixManager::get()->translate(0.0f, 1.0f, 0.0f);
		glUniformMatrix4fv(ShaderManager::get()->program()->uniforms[uniMatrixProjModelView], 1, GL_FALSE, MatrixManager::get()->matrixProjModelView());
		if (i == 7) // Highlight axis
			setLightColor(0.0f, 1.0f, 0.0f);
		else
			setLightColor();
		
		glVertexAttribPointer(VERTEX_ARRAY, 2, GL_FLOAT, 0, 0, v);
		glDrawArrays(GL_LINES, 0, 2);
	}
	MatrixManager::get()->popMatrix();
	
	// Vertical grid
	MatrixManager::get()->pushMatrix();
	MatrixManager::get()->rotate(90.0f, 0.0f, 0.0f, 1.0f);
	MatrixManager::get()->translate(0.0f, -8.0f, 0.0f);
	for (GLbyte i = 0; i < 15; i++)
	{
		MatrixManager::get()->translate(0.0f, 1.0f, 0.0f);
		glUniformMatrix4fv(ShaderManager::get()->program()->uniforms[uniMatrixProjModelView], 1, GL_FALSE, MatrixManager::get()->matrixProjModelView());
		if (i == 7)
			setLightColor(0.0f, 1.0f, 0.0f);
		else
			setLightColor();
		
		glVertexAttribPointer(VERTEX_ARRAY, 2, GL_FLOAT, 0, 0, v);
		glDrawArrays(GL_LINES, 0, 2);
	}
	MatrixManager::get()->popMatrix();
}
