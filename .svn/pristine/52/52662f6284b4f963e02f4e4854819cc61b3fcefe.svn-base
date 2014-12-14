/*
 *  ParticleHolder.h
 *  ParticleSystem
 *
 *  Created by Arkadiev on 3.9.2011.
 *  Copyright 2011 Hoof & Horn Company. All rights reserved.
 *
 */

#include "Texture.h"
#include "Matrix.h"
#include "PVRTVector.h"
#include "SmokeShader.h"
#include "Shader.h"
#include <OpenGLES/ES2/gl.h>

struct PVRTVec3;
struct PVRTVec4;

struct PVRTMat4;

class SmokeShader;

static float fract(float f) { return f - roundf(f); }

typedef unsigned int uint;

/*
	Class wich created to get mastery of the fog
 */
class FogHolder {

	// Inner physics of every chunk of fog
	struct FogChunk {
		PVRTVec4 location, velocity;
	};

	// F / m, because fog chunks mass is constant
	PVRTVec4 acceleration;

	// the driver
	SmokeShader * smoker;
	
	// what will we show
	Texture texture;
	
	// global time counter (to dispatch particles)
	// ringed, to not to come to overflow when some geek will sit to play
	float time;
	
	int count, height;
	
	// little overfoggin' 'll not harm - it will teleport too old particles
	// to their new places 
	FogChunk * chunkRing;

	// ring-iterators
	int fst, lst;
	
public:
	FogHolder(Texture texture, PVRTVec4 acceleration = PVRTVec4(1.48f, 0.0f, 0.0f, 1.0f), int count = 400, int height = 200): 
	texture(texture), 
	fst(0),
	acceleration(acceleration),
	time(1000.0),
	count(count),
	height(height),
	chunkRing(new FogChunk[count])
	{
		// load shader
		const char *vertexProgram = [[[NSBundle mainBundle] pathForResource:@"SmokeParticleSystem" ofType:@"vsh"] cStringUsingEncoding:NSUTF8StringEncoding];
		const char *fragmentProgram = [[[NSBundle mainBundle] pathForResource:@"SmokeParticleSystem" ofType:@"fsh"] cStringUsingEncoding:NSUTF8StringEncoding];
		
		// create shader
		smoker = new SmokeShader(vertexProgram, fragmentProgram);
	
		for (int i = 0; i < count; i++) {
			chunkRing[i].location = PVRTVec4(0.0, 0.0, 0 * (float)rand() / RAND_MAX * 2 - 1 , 1.0);
		}
	}
	
	~FogHolder() { delete smoker; delete chunkRing; }
	
	void Update(float dtime) {
		time += dtime;
	}
	
	void EmitPoint(bool tick, PVRTVec4 pt, PVRTVec4 velocity = PVRTVec4((float)rand() / RAND_MAX * 10.0, 20.0, 0.0, 1.0)) {
		
		if (tick) return;
		
		pt.x /= 157.0;
		pt.y /= 157.0;
		
		chunkRing[fst].location.x = (pt.x / pt.w);
		chunkRing[fst].location.y = (pt.y / pt.w);
		
		chunkRing[fst].location.z = -time * (acceleration.x, 1) + 0.1 * ((float)rand() / RAND_MAX) * (0.5 / count);
		
		chunkRing[fst].velocity = velocity;
		
		++fst %= count;
	}
	
	void Draw() {
		MatrixManager * m = MatrixManager::get();
		
		smoker->Use();
		
		// Blend particles
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		texture.use(0);
		
		// Set the sampler texture unit to 0
		glUniform1i(smoker->_uniformsLocation[SmokeShader::UniformTextureSampler], 0);
		
		glUniformMatrix4fv(smoker->_uniformsLocation[SmokeShader::UniformViewInverseMatrix], 1, GL_FALSE, m->matrixModelViewInversed());
		glUniformMatrix4fv(smoker->_uniformsLocation[SmokeShader::UniformViewProjMatrix], 1, GL_FALSE, m->matrixProjModelView());
		
		float center[4] = { -1.0f, -1.0f, 0.0f, 1.0f };  
		
		glUniform4fv(smoker->_uniformsLocation[SmokeShader::UniformParticleSystemPosition], 1, center);
		glUniform1f(smoker->_uniformsLocation[SmokeShader::UniformTime_0_X], time);
		glUniform1f(smoker->_uniformsLocation[SmokeShader::UniformParticleSystemHeight], height);
		glUniform1f(smoker->_uniformsLocation[SmokeShader::UniformParticleSpeed], (acceleration.x, 1));
		glUniform1f(smoker->_uniformsLocation[SmokeShader::UniformParticleSpread], 20.0f);
		glUniform1f(smoker->_uniformsLocation[SmokeShader::UniformParticleSystemShape], 1.2f);
		glUniform1f(smoker->_uniformsLocation[SmokeShader::UniformParticleSize], 125.0f);
		
		glVertexAttribPointer(smoker->_attributesLocation[SmokeShader::AttributeSpeed], 4, GL_FLOAT, GL_FALSE, (sizeof(PVRTVec4) * 2), &(chunkRing[0].velocity));
		glVertexAttribPointer(smoker->_attributesLocation[SmokeShader::AttributeVertex], 4, GL_FLOAT, GL_FALSE, (sizeof(PVRTVec4) * 2), &(chunkRing[0].location));
		
		glDrawArrays(GL_POINTS, 0, count);
		
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
};