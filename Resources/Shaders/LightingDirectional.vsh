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
uniform highp mat3 uniMatrixModelViewIT;

uniform highp	vec3  uniLightDir;
uniform lowp	vec4  uniLightColor;

varying mediump vec2	varTexCoord;
varying lowp	vec4	varDiffuseLight;

// General Blinn-Phong lighting function
void main()
{
	gl_Position = uniMatrixProjModelView * vec4(attrVertexCoord, 1.0);
	varTexCoord = attrTexCoord;

	highp vec3 evNormal = normalize(uniMatrixModelViewIT * attrNormalCoord);

	// Initalize light intensity varyings
	varDiffuseLight = vec4(0.4, 0.4, 0.4, 1.0); // Generic for light source and destination

	lowp float NdotL = max(dot(evNormal, uniLightDir), 0.0);
	varDiffuseLight += uniLightColor * NdotL;
}
