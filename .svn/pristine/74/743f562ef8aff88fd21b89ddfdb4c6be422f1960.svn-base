/*
 *  Shader.h
 *  Kamikaze
 *
 *  Created by Hellcat on 1/17/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef SHADER_H
#define SHADER_H

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "iostream" // For std::string, the bundle dir

#include "Singleton.h" // Wrap matrix with singleton

// List of all shader programs created for this application
typedef enum
{	
	eShaderBasic = 0,
	eShaderBasicTexture,
	eShaderBasicTextureColored,
	eShaderLightingPositional,
	eShaderLightingDirectional,
	eShaderLightingSpotted,
	eShaderNormalMapping,
	eShaderNormalReflectMapping,
	eShaderNumPrograms
} ShaderProgram;

// Vertex attributes
// Let's use the same vertex attributes array for all shader programs, to reduce complexity
// and to bring consistence between all shader programs.
// TODO: If proves needed, consider adding new attrib arrays for shaders that require less attribs
typedef enum { VERTEX_ARRAY=0, NORMAL_ARRAY=1, TEXCOORD_ARRAY=2, TANGENT_ARRAY=3, eShaderNumVertexAttribs } VertexAttribute;

// Uniforms
typedef
enum
{
	uniMatrixProjModelView = 0, uniMatrixModelView, uniMatrixModelViewIT,
	uniLightDir, uniLightPos, uniLightColor,
	spiritness,
	uniAlpha, // Separate uniform, to not mult entire uniLightColor in fragshader
	eShaderNumUniforms
} ShaderUniform;


// Class to manage multiple shader programs
class Shader
{
public:
	Shader();
	virtual ~Shader();

public: // Variables
	class Program
	{
	public:
		Program(GLbyte numAttribs) : programId(0), vShaderId(0), fShaderId(0), numVertexAttribs(0) { numVertexAttribs = numAttribs; }
		~Program()
		{
			glDetachShader(programId, vShaderId);
			glDetachShader(programId, fShaderId);
			glDeleteShader(vShaderId);
			glDeleteShader(fShaderId);
			glDeleteProgram(programId);
		};

		GLuint programId; // GL internal program id
		GLuint vShaderId;
		GLuint fShaderId;
		GLbyte uniforms[eShaderNumUniforms]; // Max number of uniforms, fixed array for now (speed)
		GLbyte numVertexAttribs; // Number of vertex attribs used by shader

		// Enable/disable vertex attribs, respect actual number of shader attribs
		void enableAttribs() { for (GLbyte i = 0; i < numVertexAttribs; ++i) glEnableVertexAttribArray(i); }
		void disableAttribs() { for (GLbyte i = 0; i < numVertexAttribs; ++i) glDisableVertexAttribArray(i); }
	};

public: // Methods
	// Accepts program type, returns Program reference, and makes the program active
	void useProgram(ShaderProgram shaderProgram) { _program = mPrograms[shaderProgram]; glUseProgram(_program->programId); }
	const Program * program() const { return _program; }

private: // Variables
	Program * mPrograms[eShaderNumPrograms];
	int numPrograms; // Actual number of loaded shader programs
	const char * vertexAttribNames[eShaderNumVertexAttribs]; // Vertex attributes, one for all shader programs
	const char * uniformNames[eShaderNumUniforms]; // Array of uniforms for the light shader, corresponds to LightUniforms indices
	Program * _program; // Shader program that is currently in use

private: // Methods
	// Assuming attribs are always of fixed names
	bool addProgram(ShaderProgram shaderProgram, const char * vShaderName, const char * fShaderName, int numVertexAttribs);
};

typedef Singleton<Shader> ShaderManager;

#endif // #ifdef SHADER_H
