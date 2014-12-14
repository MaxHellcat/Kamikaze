//
//  Shader.vsh
//  Kamikaze
//
//  Created by Hellcat on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

attribute highp vec3 attrVertexCoord;
attribute highp vec3 attrNormalCoord;
attribute highp vec2 attrTexCoord;

uniform highp mat4 uniMatrixProjModelView;
uniform highp mat4 uniMatrixModelView;
uniform highp mat3 uniMatrixModelViewIT;

uniform highp	vec3 uniLightPos;
uniform highp	vec3 uniLightDir;
uniform lowp	vec4 uniLightColor;

varying mediump vec2 varTexCoord;
varying lowp	vec4 varDiffuseLight;

const highp float  cSpotCutoff = 0.9;
//const highp float  cSpotCutoff = 45.0; // [0, 90] and the special value 180 are accepted
const highp float  cSpotExp = 50.0; // [0..128]

// General Blinn-Phong lighting function
void main()
{
	gl_Position = uniMatrixProjModelView * vec4(attrVertexCoord, 1.0);
	varTexCoord = attrTexCoord;

	highp vec3 evNormal = normalize(uniMatrixModelViewIT * attrNormalCoord);
	highp vec3 evPosition = vec3(uniMatrixModelView * vec4(attrVertexCoord, 1.0));

	// Initalize light intensity varyings
	varDiffuseLight = vec4(0.4, 0.4, 0.4, 1.0); // Generic for light source and destination

	// Calculate normalized light direction
	highp vec3 lightDir = -normalize(evPosition - uniLightPos);

	// uniLightDir is spot direction here
	highp float spotDot = dot(lightDir, uniLightDir);
	highp float attenuation = 0.0;

	if (spotDot > cSpotCutoff)
		attenuation = pow(spotDot, cSpotExp);

	lowp float NdotL = max(dot(evNormal, lightDir), 0.0);
	varDiffuseLight += attenuation * NdotL * uniLightColor;
}
