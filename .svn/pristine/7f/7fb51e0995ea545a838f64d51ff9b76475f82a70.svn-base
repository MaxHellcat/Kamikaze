/*
 *  Matrix.h
 *  shader
 *
 *  Created by Hellcat on 11/26/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef MATRIX_H
#define MATRIX_H

// Standard includes MUST come first
#include "memory.h" // For memcpy()
#include "stdio.h" // For printf()

#ifdef __APPLE__
#include <TargetConditionals.h>
#include <Availability.h>

#include "Math/Neon/math_neon.h"

#ifdef __arm__
#include "arm/arch.h"
//#include "math/neon/math_neon.h"

#endif // #ifdef __arm__
#endif // #ifdef __APPLE__

#include "Singleton.h" // Wrap matrix with singleton

#define MATRIX_SIZE_4X4	16
#define MATRIX_SIZE_3X3	9
#define MODELVIEW_STACK_SIZE		5
//#define PROJECTION_STACK_SIZE		1 // Only one proj matrix for now

//#define PVRT_MIN(a,b)            (((a) < (b)) ? (a) : (b))
#define ABS(A)	({ __typeof__(A) __a = (A); __a < 0 ? -__a : __a; })

// See common OpenGL pitfalls, http://www.opengl.org/resources/features/KilgardTechniques/oglpitfall/


// Class to manage matrix stack and various matrix operations
// The aim is to duplicate the OpenGL ES < 2.0 fixed-functionality
// As a result, names of methods are the same without prefix gl, and types
// and number of parameters are kept close as much as possible.
// Method descriptions are taken from the OpenGL 1.1 documentation, for the
// references see: http://www.khronos.org/opengles/sdk/1.1/docs/man/
// Implements a very fast matrix stack, for push/pop operations
// All matrix operations are COLUMN MAJOR
class Matrix
{
public:
	Matrix();
	~Matrix();

	typedef enum { eModelViewMatrix = 0, eProjectionMatrix, eTextureMatrix } MatrixMode;

public: // Methods
	void matrixMode(const MatrixMode mode) { mCurrentMatrixMode = mode; }

	void loadIdentity();
	void scale(const float x, const float y, const float z);

	void ortho(const float left, const float right, const float bottom, const float top, const float near, const float far);
	void perspective(const float fov_radians, const float zNear, const float zFar);
	void perspectiveFloatDepth(float fovy, float nearPlane);

	// Note: Angles in degrees
	// This rotation follows the right-hand rule, so if the vector xyz points
	// toward the user, the rotation will be counterclockwise.
	void rotate(const float angle, float x, float y, float z); // Any axis rotate

	// Translation, like glTranslate
	void translate(const float x, const float y, const float z);
	void lookAt(float xEye, float yEye, float zEye, float xAt, float yAt, float zAt, float xUp, float yUp, float zUp);
	void mult(float * m1, float * m2, float * result);

	// Stack operations
	void pushMatrix();
	void popMatrix();

	const float * matrixModelView() { return mStackMatrixModelView[mTopMatrixIndex]; }
	const float * matrixModelViewInversed();
	const float * matrixModelViewTransposed();
	const float * matrixModelViewIT();
	const float * matrixProjection() { return mMatrixProjection; }
	const float * matrixProjModelView();

private: // Variables
	float * mStackMatrixModelView[MODELVIEW_STACK_SIZE]; // Stack of matrices, with the only one "top" active
	int mTopMatrixIndex; // Top (currently used) matrix in the stack
	float mMatrixProjection[MATRIX_SIZE_4X4]; // Projection matrix (only one, should be enough for now)
	float mMatrixTmp4x4[MATRIX_SIZE_4X4]; // Temporary matrix for multiplications (2nd operand)
	float mMatrixResult4x4[MATRIX_SIZE_4X4]; // Result matrix for multiplications
	float mMatrixResult3x3[MATRIX_SIZE_3X3]; // A 3x3 result matrix, for inversed matrix

	MatrixMode mCurrentMatrixMode; // Initial matrix is ModelView
};

typedef Singleton<Matrix> MatrixManager;

#endif /* MATRIX_H */
