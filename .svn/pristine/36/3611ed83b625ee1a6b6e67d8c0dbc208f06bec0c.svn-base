/*
 *  Shader.cpp
 *  ParticleSystem
 *
 *  Created by Артем on 3/1/11.
 *  Copyright 2011 Hoof & Horn Company. All rights reserved.
 *
 */

#include "SmokeShader.h"

#include <assert.h>

#include "PVRTShader.h" // Shaders
#include "PVRTgles2Ext.h" // For defines, like GL_SGX_BINARY_IMG

///////////////////////////////////////////////////////////////////////////////
SmokeShader::SmokeShader(const char *vertexProgramName, const char *fragmentProgramName) {
	_attributesNames[AttributeVertex] = "aVertex";
	_attributesNames[AttributeSpeed] = "aSpeed";
	
	_uniformsNames[UniformTime_0_X]					= "uTime_0_X";
	_uniformsNames[UniformViewInverseMatrix]		= "uViewInverseMatrix";
	_uniformsNames[UniformViewProjMatrix]			= "uViewProjMatrix";
	_uniformsNames[UniformParticleSystemHeight]		= "uParticleSystemHeight";
	_uniformsNames[UniformParticleSpeed]			= "uParticleSpeed";
	_uniformsNames[UniformParticleSpread]			= "uParticleSpread";
	_uniformsNames[UniformParticleSystemShape]		= "uParticleSystemShape";
	//_uniformsNames[UniformParticleShape]			= "uParticleShape";
	_uniformsNames[UniformParticleSize]				= "uParticleSize";
	_uniformsNames[UniformParticleSystemPosition]	= "uParticleSystemPosition";
	_uniformsNames[UniformTextureSampler]			= "sTexture";
	
	Create(vertexProgramName, fragmentProgramName);
}
///////////////////////////////////////////////////////////////////////////////
SmokeShader::~SmokeShader() {
	glDeleteProgram(_ID);
	glDeleteShader(_vertexProgramID);
	glDeleteShader(_fragmentProgramID);
}
///////////////////////////////////////////////////////////////////////////////
void SmokeShader::Use() {
	glUseProgram(_ID);
}
///////////////////////////////////////////////////////////////////////////////
void SmokeShader::EnableAttributes() {
#if defined(DEBUG)
	Validate();
#endif

	for (GLuint i = 0; i < AttributeCount; ++i) {
		glEnableVertexAttribArray(i);
	}
}
///////////////////////////////////////////////////////////////////////////////
void SmokeShader::DisableAttributes() {
	for (GLuint i = 0; i < AttributeCount; ++i) {
		glDisableVertexAttribArray(i);
	}
}
///////////////////////////////////////////////////////////////////////////////
void SmokeShader::Create(const char *vertexProgramFile, const char *fragmentProgramFile) {
	CPVRTString pErrorStr;
	
	EPVRTError operationResult;
	
	operationResult = PVRTShaderLoadFromFile(0, vertexProgramFile, GL_VERTEX_SHADER, GL_SGX_BINARY_IMG, &_vertexProgramID, &pErrorStr);
	assert(PVR_SUCCESS == operationResult);
	
	operationResult = PVRTShaderLoadFromFile(0, fragmentProgramFile, GL_FRAGMENT_SHADER, GL_SGX_BINARY_IMG, &_fragmentProgramID, &pErrorStr);
	assert(PVR_SUCCESS == operationResult);
	
	operationResult = PVRTCreateProgram(&_ID, _vertexProgramID, _fragmentProgramID, _attributesNames, AttributeCount, &pErrorStr);
	assert(PVR_SUCCESS == operationResult);

	for (int i = 0; i < AttributeCount; ++i) {
		_attributesLocation[i] = glGetAttribLocation(_ID, _attributesNames[i]);
		assert(-1 != _attributesLocation[i]); // all attributes must exist
	}
	
	for (int i = 0; i < UniformCount; ++i) {
		_uniformsLocation[i] = glGetUniformLocation(_ID, _uniformsNames[i]);
		assert(-1 != _uniformsLocation[i]); // all uniforms must exist
	}
}
///////////////////////////////////////////////////////////////////////////////
void SmokeShader::Validate() {
    glValidateProgram(_ID);
	
	GLint logLength;
	glGetProgramiv(_ID, GL_INFO_LOG_LENGTH, &logLength);
    
	if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        
		glGetProgramInfoLog(_ID, logLength, &logLength, log);
		
		printf("Program vaildate log:\n%s", log);
        
		free(log);
    }
	
	GLint status;
	glGetProgramiv(_ID, GL_VALIDATE_STATUS, &status);
	
	assert(GL_TRUE == status);
}
///////////////////////////////////////////////////////////////////////////////
