uniform float uTime_0_X;
uniform mat4  uViewInverseMatrix;
uniform mat4  uViewProjMatrix;
uniform float uParticleSystemHeight;
uniform float uParticleSpeed;
uniform float uParticleSpread;
uniform float uParticleSystemShape;
//uniform float uParticleShape;
uniform float uParticleSize;
uniform vec4  uParticleSystemPosition;

// The model for the particle system consists of a hundred quads.
// These quads are simple (-1,-1) to (1,1) quads where each quad
// has a z ranging from 0 to 1. The z will be used to differenciate
// between different particles

attribute vec4 aVertex;
attribute vec4 aSpeed;

varying vec2  vTexCoord;
varying float vColor;

void main(void)
{  
   // Loop particles
   float t = fract(aVertex.z + uParticleSpeed * uTime_0_X * 1.0);
   // Determine the shape of the system
   float s = pow(t, uParticleSystemShape);

   vec3 pos;
   // Spread particles in a semi-random fashion
   // For better quality necessary add noise-texture and read values from it.
   pos.y = uParticleSpread * s * sin(360.0 * (aVertex.z)) / 5.0;
   pos.x = uParticleSpread * s * sin(360.0 * (aVertex.z)) / 5.0;
   pos.z = -(fract(t) * 0.0 + aVertex.z) / 1000.0; // uParticleSpread * s * cos(360.0 * (aVertex.z + 1.0));

   // Particles goes up
   // For more flexible particle system necessary use velocity vector instead of this approach.
   pos.x -= uParticleSystemHeight * 2.0 * t * 0.1;

   // Billboard the quads.
   // The view matrix gives us our right and up vectors.
   pos += 150.0 * (aVertex.x * uViewInverseMatrix[0] + aVertex.y * uViewInverseMatrix[1]).xyz;
   // And put the system into place
   pos += uParticleSystemPosition.xyz;
   
   pos.xy += aSpeed.xy * (0.03 - t * 23.5);
   
   gl_PointSize = uParticleSize * t * 0.95 * 16.0;
   
   gl_Position = uViewProjMatrix * vec4(pos, 1.0);
   
//   vTexCoord = aVertex.xy;
   vColor    = 0.9 + t * 50.0; //(1.0 - (t * 7.5)) * 2.0;   
}