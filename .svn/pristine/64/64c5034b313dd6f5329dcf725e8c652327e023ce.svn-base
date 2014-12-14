/*
 *  Shader.h
 *  ParticleSystem
 *
 *  Created by Артем on 3/1/11.
 *  Copyright 2011 Hoof & Horn Company. All rights reserved.
 *
 */

#ifndef SMOKE_SHADER_H
#define SMOKE_SHADER_H

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

/**
 * Would be better use classes for GPU program's attribute ans uniform.
 * Shader must configure by mihself by calling method with some parameters
 * like particle emitter or something else for others shaders.
 * It's make code more convenient and general-purpose.
 */

class SmokeShader {
public:
	SmokeShader(const char *vertexProgramName, const char *fragmentProgramName);
	~SmokeShader();

	enum Attribute {
		AttributeVertex = 0,
		AttributeSpeed,
		AttributeCount
	};

	enum Uniform {
		UniformTime_0_X = 0,
		UniformViewInverseMatrix,
		UniformViewProjMatrix,
		UniformParticleSystemHeight,
		UniformParticleSpeed,
		UniformParticleSpread,
		UniformParticleSystemShape,
		//UniformParticleShape,
		UniformParticleSize,
		UniformParticleSystemPosition,
		UniformTextureSampler,
		UniformCount
	};
	
	void Use();
	
	void EnableAttributes();
	void DisableAttributes();

private:
	void Validate();
	
	void Create(const char *vertexProgramFile, const char *fragmentProgramFile);
	
private:
	GLuint _ID; // GPU program unique ID.
	GLuint _vertexProgramID;
	GLuint _fragmentProgramID;

public:
	const char *_attributesNames[AttributeCount];
	int _attributesLocation[AttributeCount];
	const char *_uniformsNames[UniformCount];
	int _uniformsLocation[UniformCount];
};

#endif // #ifdef SMOKE_SHADER_H
