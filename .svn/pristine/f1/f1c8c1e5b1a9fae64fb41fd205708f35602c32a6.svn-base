/*
 *  Shader.cpp
 *  Kamikaze
 *
 *  Created by Hellcat on 1/17/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "Shader.h"

#include "PowerVRTools/OGLES2/PVRTShader.h" // Shaders
#include "PowerVRTools/OGLES2/PVRTgles2Ext.h" // For defines, like GL_SGX_BINARY_IMG

#include "Misc.h"

Shader::Shader() : _program(0), numPrograms(0)
{
	// Vertex attributes
	// Warning: The attribute names below MUST be equal to the ones used in all shaders
	vertexAttribNames[VERTEX_ARRAY] = "attrVertexCoord";
	vertexAttribNames[NORMAL_ARRAY] = "attrNormalCoord";
	vertexAttribNames[TEXCOORD_ARRAY] = "attrTexCoord";
	vertexAttribNames[TANGENT_ARRAY] = "attrTanCoord";

	// Uniforms
	// Warning: The uniform names below MUST be equal to the ones used in all shaders
	// Note: To avoid crazy branching, We use simplified approach of registering
	// ALL uniforms per each program, but some of programs have much fewer ones, in this connection ->
	// TODO: Workout whether redundantly register uniforms affect speed of shaders that don't have them declared
	uniformNames[uniMatrixProjModelView] = "uniMatrixProjModelView";
	uniformNames[uniMatrixModelView] = "uniMatrixModelView";
	uniformNames[uniMatrixModelViewIT] = "uniMatrixModelViewIT";
	uniformNames[uniLightDir] = "uniLightDir";
	uniformNames[uniLightPos] = "uniLightPos";
	uniformNames[uniLightColor] = "uniLightColor";
	uniformNames[spiritness] = "spiritness";
	uniformNames[uniAlpha] = "uniAlpha";

	// Compile, link and load shader programs
	// Warning: The order of shaders creation is important and MUST follow Shader::ShaderProgram order!
	// Note: In the 3rd parameter specify the max possible vertex attrib that is used by the shader
	addProgram(eShaderBasic, "Basic.vsh", "Basic.fsh", VERTEX_ARRAY);
	addProgram(eShaderBasicTexture, "BasicTexture.vsh", "BasicTexture.fsh", TEXCOORD_ARRAY);
	addProgram(eShaderBasicTextureColored, "BasicTextureColored.vsh", "BasicTextureColored.fsh", TEXCOORD_ARRAY);
	addProgram(eShaderLightingPositional, "LightingPositional.vsh", "LightingPositional.fsh", TEXCOORD_ARRAY);
	addProgram(eShaderLightingDirectional, "LightingDirectional.vsh", "LightingDirectional.fsh", TEXCOORD_ARRAY);
	addProgram(eShaderLightingSpotted, "LightingSpotted.vsh", "LightingSpotted.fsh", TEXCOORD_ARRAY);
	addProgram(eShaderNormalMapping, "NormalMapping.vsh", "NormalMapping.fsh", TANGENT_ARRAY);
	addProgram(eShaderNormalReflectMapping, "NormalReflectMapping.vsh", "NormalReflectMapping.fsh", TANGENT_ARRAY);


	// WEAK PLACE
	// Enable by default the vertex attribs below, to not enabling/disabling when drawing
	// WARNING: As a result, you MUST be sure you don't disable these attribs
	// anywhere by accident! (PowerVR printing is known to cause these troubles)
	// TODO: Find out if enabled attribs cause delays in shaders when not used
	glEnableVertexAttribArray(VERTEX_ARRAY); // Enable, no vertices - no anything
	glEnableVertexAttribArray(NORMAL_ARRAY); // Enable/disable?, only needed if light and more
	glEnableVertexAttribArray(TEXCOORD_ARRAY); // Enable, almost everything textured
//	glEnableVertexAttribArray(TANGENT_ARRAY); // Disable, only for normal mapping
}

Shader::~Shader()
{
	glDisableVertexAttribArray(VERTEX_ARRAY);
	glDisableVertexAttribArray(NORMAL_ARRAY);
	glDisableVertexAttribArray(TEXCOORD_ARRAY);
	glDisableVertexAttribArray(TANGENT_ARRAY);

	for (GLubyte i = 0; i < numPrograms; ++i)
	{
		Program * program = mPrograms[i];
		if (program)
		{
			delete program;
		}
		program = 0;
	}
}

bool Shader::addProgram(ShaderProgram shaderProgram, const char * vShaderName, const char * fShaderName, int numVertexAttribs)
{
	Program * program = 0;

	try { program = new Program(++numVertexAttribs); }
	catch (std::bad_alloc & exc) { printf("ERROR: Failed to allocate memory for shader program\n"); return false; }

	// Load and compile the shaders from files
	CPVRTString pErrorStr;
	if (PVRTShaderLoadFromFile(0, (Bundle::get()->path() + vShaderName).c_str(), GL_VERTEX_SHADER, GL_SGX_BINARY_IMG, &program->vShaderId, &pErrorStr) != PVR_SUCCESS)
	{
		printf("ERROR in shader %s: %s", vShaderName, pErrorStr.c_str());
		return false;
	}

	if (PVRTShaderLoadFromFile(0, (Bundle::get()->path() + fShaderName).c_str(), GL_FRAGMENT_SHADER, GL_SGX_BINARY_IMG, &program->fShaderId, &pErrorStr) != PVR_SUCCESS)
	{
		printf("ERROR in shader %s: %s", fShaderName, pErrorStr.c_str());
		return false;
	}

	// Set up and link shader program
	if (PVRTCreateProgram(&program->programId, program->vShaderId, program->fShaderId, vertexAttribNames, numVertexAttribs, &pErrorStr) != PVR_SUCCESS)
	{
		printf("ERROR: %s", pErrorStr.c_str());
		return false;
	}

	// Store the location of uniforms for later quick access
	for (GLushort i = 0; i < eShaderNumUniforms; ++i)	program->uniforms[i] = glGetUniformLocation(program->programId, uniformNames[i]);

	// Assign texture units (should be at least 8 for a shader)
	// Beware here. Different shaders don't have this number of units and so for them we shouldn't assign at all
	// For now just simple attribute count check
	if (numVertexAttribs > TANGENT_ARRAY)
	{ // If shader uses tangents, then enable normal map texure
		glUniform1i(glGetUniformLocation(program->programId, "texUnit1"), 1);
		glUniform1i(glGetUniformLocation(program->programId, "texUnit2"), 2);
	}
	else if (numVertexAttribs > TEXCOORD_ARRAY)
	{ // Else enable diffuse texture only
		glUniform1i(glGetUniformLocation(program->programId, "texUnit0"), 0);
	}

	mPrograms[numPrograms++] = program; // Add initialized shader program into container

	return true;
}
