/*
 *  Matrix.cpp
 *  shader
 *
 *  Created by Hellcat on 11/26/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Matrix.h"

#include "iostream" // For std::bad_alloc exception

#include "constants.h"

// Create pair of matrices and set default matrix mode to ModelView
Matrix::Matrix()
: mTopMatrixIndex(0), mCurrentMatrixMode(eModelViewMatrix)
{
	try
	{
		for (short i = 0; i < MODELVIEW_STACK_SIZE; i++) { mStackMatrixModelView[i] = new float[MATRIX_SIZE_4X4]; }
	}
	catch (std::bad_alloc & exc)
	{
		for (short i = 0; i < MODELVIEW_STACK_SIZE; i++)
		{
			if (mStackMatrixModelView[i]) delete mStackMatrixModelView[i];
			mStackMatrixModelView[i] = 0;
		}
		throw kErrBadAllocation; // Core ctor will catch this and rethrow to GLView
	}
}

Matrix::~Matrix()
{
	for (short i = 0; i < MODELVIEW_STACK_SIZE; i++)
	{
		if (mStackMatrixModelView[i])
			delete [] mStackMatrixModelView[i];
		mStackMatrixModelView[i] = 0;
	}
}

// Replace the current matrix with the identity matrix
void Matrix::loadIdentity()
{
	float * matrix;
	(mCurrentMatrixMode == eModelViewMatrix)?matrix = mStackMatrixModelView[mTopMatrixIndex]:matrix = mMatrixProjection;

	matrix[ 0] = 1.0f;	matrix[ 4] = 0.0f;	matrix[ 8] = 0.0f;	matrix[12] = 0.0f;
	matrix[ 1] = 0.0f;	matrix[ 5] = 1.0f;	matrix[ 9] = 0.0f;	matrix[13] = 0.0f;
	matrix[ 2] = 0.0f;	matrix[ 6] = 0.0f;	matrix[10] = 1.0f;	matrix[14] = 0.0f;
	matrix[ 3] = 0.0f;	matrix[ 7] = 0.0f;	matrix[11] = 0.0f;	matrix[15] = 1.0f;
}

// Multiply the current matrix by a general scaling matrix
// Note: The current matrix is multiplied by this scale matrix, and the product
// replaces the current matrix
void Matrix::scale(const float x, const float y, const float z)
{
	float * ma = (mCurrentMatrixMode == eModelViewMatrix)?mStackMatrixModelView[mTopMatrixIndex]:mMatrixProjection;
	float * mb = mMatrixTmp4x4;

	mb[ 0] = x;		mb[ 4] = 0.0f;	mb[ 8] = 0.0f;	mb[12] = 0.0f;
	mb[ 1] = 0.0f;	mb[ 5] = y;		mb[ 9] = 0.0f;	mb[13] = 0.0f;
	mb[ 2] = 0.0f;	mb[ 6] = 0.0f;	mb[10] = z;		mb[14] = 0.0f;
	mb[ 3] = 0.0f;	mb[ 7] = 0.0f;	mb[11] = 0.0f;	mb[15] = 1.0f;

	mult(ma, mb, ma);
}

// Multiply the current matrix with an orthographic matrix
// Note: Typically, the matrix mode is GL_PROJECTION, so use it only
void Matrix::ortho(const float left, const float right, const float bottom, const float top, const float near, const float far)
{
	float * ma = mMatrixProjection;
	float * mb = mMatrixTmp4x4;

	const float dx = right - left;
	const float dy = top - bottom;
	const float dz = far - near;
	const float tx = - (right + left) / dx;
	const float ty = - (top + bottom) / dy;
	const float tz = - (far + near) / dz;

	mb[0] = 2.0f / dx;
	mb[1] = 0.0f;
	mb[2] = 0.0f;
	mb[3] = 0.0f;

	mb[4] = 0.0f;
	mb[5] = 2.0f / dy;
	mb[6] = 0.0f;
	mb[7] = 0.0f;

	mb[8] = 0.0f;
	mb[9] = 0.0f;
	mb[10] = -2.0f / dz;
	mb[11] = 0.0f;

	mb[12] = tx;
	mb[13] = ty;
	mb[14] = tz;
	mb[15] = 1.0f;

	mult(ma, mb, ma);
}

// Multiply the current matrix by a perspective matrix
// Note: Almost glFrustum, but parameters changed for convenience
// Note: Typically, the matrix mode is GL_PROJECTION, so use it only
// Note: Modify to mimic glFustum if needed
// TODO: Test this method!
void Matrix::perspective(const float fov_radians, const float zNear, const float zFar)
{
//	float * ma = mMatrixProjection;
//	float * mb = mMatrixTmp4x4;
	float * mb = mMatrixProjection;

	const float f = 1.0f / tanf_neon(fov_radians * 0.5f);

	mb[0] = f;		mb[4] = 0.0f;	mb[8] = 0.0f;							mb[12] = 0.0f;
	mb[1] = 0.0f;	mb[5] = f;		mb[9] = 0.0f;							mb[13] = 0.0f;
	mb[2] = 0.0f;	mb[6] = 0.0f;	mb[10] = (zFar+zNear) / (zNear-zFar);	mb[14] = (2.0f*zFar*zNear) / (zNear-zFar);
	mb[3] = 0.0f;	mb[7] = 0.0f;	mb[11] = -1.0f;							mb[15] = 0.0f;
	
//	mult(ma, mb, ma);
}

void Matrix::perspectiveFloatDepth(float fovy, float nearPlane)
{
	float * ma = mMatrixProjection;
	float * mc = mMatrixResult4x4;
//	float * mc = mMatrixProjection;

	float height = (2.0f * nearPlane) * tanf_neon(fovy * 0.5f);
	float n2 = nearPlane * 4.0f;
	
//	printf("{ fovy = %f, nearPlane = %f, height = %f, n2 = %f }\n", fovy, nearPlane, height, n2);
/*
	mc[0] = -n2/height;	mc[4]=0.0f;			mc[8]=0.0f;		mc[12]=0.0f;
	mc[1] = 0.0f;		mc[5]=-n2/height;	mc[9]=0.0f;		mc[13]=0.0f;
	mc[2] = 0.0f;		mc[6]=0.0f;			mc[10]=1.0f;	mc[14]=n2; // OGL
//	mc[2] = 0.0f;		mc[6]=0.0f;			mc[10]=0.0f;	mc[14]=nearPlane; // D3D
	mc[3] = 0.0f;		mc[7]=0.0f;			mc[11]= -1.0f;	mc[15]=0.0f;
*/
/* ALSO WURKS
	mc[0] = 0.1f;		mc[4]=0.0f;			mc[8]=0.0f;		mc[12]=0.0f;
	mc[1] = 0.0f;		mc[5]=0.1f;			mc[9]=0.0f;		mc[13]=0.0f;
	mc[2] = 0.0f;		mc[6]=0.0f;			mc[10]=0.01f;	mc[14]=1.f/10.0f; // OGL
	//	mc[2] = 0.0f;		mc[6]=0.0f;			mc[10]=0.0f;	mc[14]=nearPlane; // D3D
	mc[3] = 0.0f;		mc[7]=0.0f;			mc[11]= 0.0f;	mc[15]=1.0f;
*/
	mc[0] = n2/height;	mc[4]=0.0f;			mc[8]  = 0.0f;		mc[12] = -3.f;
	mc[1] = 0.0f;		mc[5]=n2/height;	mc[9]  = 0.0f;		mc[13] = +0.0f; 
	mc[2] = 0.0f;		mc[6]=0.0f;			mc[10] = 1.f;		mc[14] = n2; // OGL
	mc[3] = 0.0f;		mc[7]=0.0f;			mc[11] = -1.f;		mc[15] = 0.0f;
	mult(ma, mc, ma);
}

// Multiply the current matrix by a rotation matrix
void Matrix::rotate(const float angle, float x, float y, float z)
{
	float * ma = mStackMatrixModelView[mTopMatrixIndex];
//	float * ma = (mCurrentMatrixMode == eModelViewMatrix)?mStackMatrixModelView[mTopMatrixIndex]:mMatrixProjection;
	float * mb = mMatrixTmp4x4;

	float vec3[3] = {x*x, y*y, z*z};
	#if (TARGET_IPHONE_SIMULATOR == 1)
		normalize3_c(vec3, vec3);
	#else
		normalize3_neon(vec3, vec3);
	#endif

	x = vec3[X]; y = vec3[Y]; z = vec3[Z];

	// Below is the place caused a lot of issues with rotate
	// Looks like either cos_neon or sin_neon or both work somehow not good
	float c = cosf_c(angle*M_PI/180.0f);
	float s = sinf_c(angle*M_PI/180.0f);
//	float c = cosf_neon(angle*M_PI/180.0f); // TODO: Find out why neon cos not working correct!

//	float c = sinf_neon(angle*M_PI/180.0f+M_PI_2); // Experimental, test it! - NOT WORKING
//	float s = sinf_neon_sfp(angle*M_PI/180.0f);

	// Proper counter clock-wise rotation
	mb[ 0] = x * x * (1.0f - c) + c;
	mb[ 1] = y * x * (1.0f - c) + (z * s);
	mb[ 2] = z * x * (1.0f - c) - (y * s);
	mb[ 3] = 0.0f;

	mb[ 4] = x * y * (1.0f - c) - (z * s);
	mb[ 5] = y * y * (1.0f - c) + c;
	mb[ 6] = z * y * (1.0f - c) + (x * s);
	mb[ 7] = 0.0f;

	mb[ 8] = x * z * (1.0f - c) + (y * s);
	mb[ 9] = y * z * (1.0f - c) - (x * s);
	mb[10] = z * z * (1.0f - c) + c;
	mb[11] = 0.0f;

	mb[12] = 0.0f;
	mb[13] = 0.0f;
	mb[14] = 0.0f;
	mb[15] = 1.0f;

	mult(ma, mb, ma);
}

// Multiply the current matrix by a translation matrix
void Matrix::translate(const float x, const float y, const float z)
{
	float * ma = mStackMatrixModelView[mTopMatrixIndex];
	float * mb = mMatrixTmp4x4;

	mb[ 0] = 1.0f;	mb[ 4] = 0.0f;	mb[ 8] = 0.0f;	mb[12] = x;
	mb[ 1] = 0.0f;	mb[ 5] = 1.0f;	mb[ 9] = 0.0f;	mb[13] = y;
	mb[ 2] = 0.0f;	mb[ 6] = 0.0f;	mb[10] = 1.0f;	mb[14] = z;
	mb[ 3] = 0.0f;	mb[ 7] = 0.0f;	mb[11] = 0.0f;	mb[15] = 1.0f;

	mult(ma, mb, ma);
}

// Note: The ModelView is replaced, not multiplied
// TODO: Finalize and test this method!
void Matrix::lookAt(float xEye, float yEye, float zEye, float xAt, float yAt, float zAt, float xUp, float yUp, float zUp)
{
	float vForward[3], vUpNorm[3], vSide[3];
	float * ma = mMatrixProjection;
	float * mc = mMatrixResult4x4;

	vForward[X] = xEye - xAt; vForward[Y] = yEye - yAt; vForward[Z] = zEye - zAt;

	float vUp[] = {xUp, yUp, zUp};

	normalize3_neon(vForward, vForward);
	normalize3_neon(vUp, vUpNorm);
	cross3_neon(vUpNorm, vForward, vSide);
	cross3_neon(vForward, vSide, vUpNorm);

	mc[0] = vSide[X];		mc[4] = vSide[Y];		mc[8] = vSide[Z];		mc[12] = 0.0f;
	mc[1] = vUpNorm[X];		mc[5] = vUpNorm[Y];		mc[9] = vUpNorm[Z];		mc[13] = 0.0f;
	mc[2] = vForward[X];	mc[6] = vForward[Y];	mc[10] = vForward[Z];	mc[14] = 0.0f;
	mc[3] = 0.0f;			mc[7] = 0.0f;			mc[11] = 0.0f;			mc[15] = 1.0f;

	mc[12] = -xEye*mc[0] + -yEye*mc[4] + -zEye*mc[8];
	mc[13] = -xEye*mc[1] + -yEye*mc[5] + -zEye*mc[9];
	mc[14] = -xEye*mc[2] + -yEye*mc[6] + -zEye*mc[10];
	mc[15] = -xEye*mc[3] + -yEye*mc[7] + -zEye*mc[11];

	mult(ma, mc, ma);
}

// Note: Post-multiplying with column-major matrices produces the same result
// as pre-multiplying with row-major matrices.
inline
void Matrix::mult(float * m1, float * m2, float * mc)
{
#if (TARGET_IPHONE_SIMULATOR == 0)/* && (TARGET_OS_IPHONE == 1)*/ // Check if we can use vector processors (yiiihaaa!)
	#ifdef _ARM_ARCH_7
		// Chips armv7 (Cortex-A8): iPhone 3GS/4, iPad
		matmul4_neon(m1, m2, mc);
//		matmul4_c(m1, m2, mMatrixResult4x4);
//		memcpy(mc, mMatrixResult4x4, sizeof(float)*MATRIX_SIZE_4X4);
	#else
		// Chips armv6: iPhone, iPhone 3g
//		Matrix4Mul(m2, m1, mc);
	#endif
#else
	// No vector co-CPU support, using software multiplication (e.g. simulator)
	matmul4_c(m1, m2, mMatrixResult4x4);

	// Copy results
	if (mMatrixResult4x4 != mc) // Don't copy into itself
		memcpy(mc, mMatrixResult4x4, sizeof(float)*MATRIX_SIZE_4X4);
#endif
}

const float * Matrix::matrixModelViewIT()
{
	// Inverse first
	matrixModelViewInversed();

	float * mb = mMatrixTmp4x4; // Now tmp matrix is inversed mv one
	float * mc = mMatrixResult4x4;

	// Now transpose inversed model-view matrix
	mc[ 0]=mb[ 0];	mc[ 4]=mb[ 1];	mc[ 8]=mb[ 2];	mc[12]=mb[ 3];
	mc[ 1]=mb[ 4];	mc[ 5]=mb[ 5];	mc[ 9]=mb[ 6];	mc[13]=mb[ 7];
	mc[ 2]=mb[ 8];	mc[ 6]=mb[ 9];	mc[10]=mb[10];	mc[14]=mb[11];
	mc[ 3]=mb[12];	mc[ 7]=mb[13];	mc[11]=mb[14];	mc[15]=mb[15];

	// Form 3x3 matrix and output
	mb = mMatrixResult3x3;
	mb[0]=mc[0];  mb[3]=mc[4];  mb[6]=mc[8];
	mb[1]=mc[1];  mb[4]=mc[5];  mb[7]=mc[9];
	mb[2]=mc[2];  mb[5]=mc[6];  mb[8]=mc[10];

	return mb;
}

inline
const float * Matrix::matrixModelViewInversed()
{
	float * ma = mStackMatrixModelView[mTopMatrixIndex];
	float * mb = mMatrixTmp4x4;

	double det_1;
	double pos, neg, temp;

	// Calculate the determinant of submatrix A and determine if the
	// the matrix is singular as limited by the double precision
	// floating-point data representation.
    pos = neg = 0.0;
    temp =  ma[ 0] * ma[ 5] * ma[10];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp =  ma[ 4] * ma[ 9] * ma[ 2];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp =  ma[ 8] * ma[ 1] * ma[ 6];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -ma[ 8] * ma[ 5] * ma[ 2];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -ma[ 4] * ma[ 1] * ma[10];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -ma[ 0] * ma[ 9] * ma[ 6];
    if (temp >= 0.0) pos += temp; else neg += temp;
    det_1 = pos + neg;

	// Is the submatrix A singular?
    if ((det_1 == 0.0f) || (ABS(det_1 / (pos - neg)) < 1.0e-15))
	{
        // Matrix M has no inverse
//		printf("Matrix - Matrix has no inverse - singular matrix\n");
        return mb;
    }
	else
	{
        // Calculate inverse(A) = adj(A) / det(A)
        det_1 = 1.0 / det_1;
        mb[ 0] =   ( ma[ 5] * ma[10] - ma[ 9] * ma[ 6] ) * (float)det_1;
        mb[ 1] = - ( ma[ 1] * ma[10] - ma[ 9] * ma[ 2] ) * (float)det_1;
        mb[ 2] =   ( ma[ 1] * ma[ 6] - ma[ 5] * ma[ 2] ) * (float)det_1;
        mb[ 4] = - ( ma[ 4] * ma[10] - ma[ 8] * ma[ 6] ) * (float)det_1;
        mb[ 5] =   ( ma[ 0] * ma[10] - ma[ 8] * ma[ 2] ) * (float)det_1;
        mb[ 6] = - ( ma[ 0] * ma[ 6] - ma[ 4] * ma[ 2] ) * (float)det_1;
        mb[ 8] =   ( ma[ 4] * ma[ 9] - ma[ 8] * ma[ 5] ) * (float)det_1;
        mb[ 9] = - ( ma[ 0] * ma[ 9] - ma[ 8] * ma[ 1] ) * (float)det_1;
        mb[10] =   ( ma[ 0] * ma[ 5] - ma[ 4] * ma[ 1] ) * (float)det_1;

        // Calculate -C * inverse(A)
        mb[12] = - ( ma[12] * mb[ 0] + ma[13] * mb[ 4] + ma[14] * mb[ 8] );
        mb[13] = - ( ma[12] * mb[ 1] + ma[13] * mb[ 5] + ma[14] * mb[ 9] );
        mb[14] = - ( ma[12] * mb[ 2] + ma[13] * mb[ 6] + ma[14] * mb[10] );

        // Fill in last row
        mb[ 3] = 0.0f;
		mb[ 7] = 0.0f;
		mb[11] = 0.0f;
        mb[15] = 1.0f;
	}

	return mb;
}

inline
const float * Matrix::matrixModelViewTransposed()
{
	float * ma = mStackMatrixModelView[mTopMatrixIndex];
	float * mb = mMatrixTmp4x4;

	mb[ 0]=ma[ 0];	mb[ 4]=ma[ 1];	mb[ 8]=ma[ 2];	mb[12]=ma[ 3];
	mb[ 1]=ma[ 4];	mb[ 5]=ma[ 5];	mb[ 9]=ma[ 6];	mb[13]=ma[ 7];
	mb[ 2]=ma[ 8];	mb[ 6]=ma[ 9];	mb[10]=ma[10];	mb[14]=ma[11];
	mb[ 3]=ma[12];	mb[ 7]=ma[13];	mb[11]=ma[14];	mb[15]=ma[15];

	return mb;
}

// Pushes the current matrix stack down by one, duplicating the current matrix.
// That is, after a glPushMatrix call, the matrix on top of the stack is identical to the one below it.
void Matrix::pushMatrix()
{
	if (mTopMatrixIndex < MODELVIEW_STACK_SIZE-1) // Only if stack limit not reached
	{
		// Switch to next matrix up the stack (well, array) and duplicate
		mTopMatrixIndex++;

		// Duplicate pushed matrix
		memcpy(mStackMatrixModelView[mTopMatrixIndex], mStackMatrixModelView[mTopMatrixIndex-1], sizeof(float)*MATRIX_SIZE_4X4);
	}
}

// Pops the current matrix stack, replacing the current matrix with the one below it on the stack.
void Matrix::popMatrix()
{
	if (mTopMatrixIndex > 0) // Only if we have pushed matrices
	{
		mTopMatrixIndex--; // Switch to the matrix below in the stack
	}
}

// Add check if any of the matrices is an identity, then don't mult with it!
const float * Matrix::matrixProjModelView()
{
	mult(mMatrixProjection, mStackMatrixModelView[mTopMatrixIndex], mMatrixResult4x4);
	return mMatrixResult4x4;
}
