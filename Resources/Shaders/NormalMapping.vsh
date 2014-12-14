// Note: In case you change the variable names below, remember to always update corresponding
// names in Shader class

attribute highp vec3 attrVertexCoord;
attribute highp vec3 attrNormalCoord;
attribute highp vec2 attrTexCoord;
attribute highp vec3 attrTanCoord;

uniform highp mat4  uniMatrixProjModelView;
uniform highp mat4  uniMatrixModelView;
uniform highp mat3  uniMatrixModelViewIT;
uniform highp vec3  uniLightPos;

varying lowp    vec3   varLightVec;
varying mediump vec2   varTexCoord;

// A shader that implements only Normal Mapping effect.
void main()
{
	gl_Position = uniMatrixProjModelView * vec4(attrVertexCoord, 1.0);
	varTexCoord = attrTexCoord;

	// Tangent, vertex and normal to eye space
	vec3 mvTangent = normalize(uniMatrixModelViewIT * attrTanCoord);
	vec3 mvNormal = normalize(uniMatrixModelViewIT * attrNormalCoord);
	vec3 mvBitangent = cross(mvNormal, mvTangent);
	vec3 mvVertex = vec3(uniMatrixModelView * vec4(attrVertexCoord, 1.0)); // Hgrr

	// Calculate light direction and actual light vector
	vec3 mvDirToLight = normalize(uniLightPos - mvVertex);
	
    varLightVec.x = dot(mvDirToLight, mvTangent);
	varLightVec.y = dot(mvDirToLight, mvBitangent);
	varLightVec.z = dot(mvDirToLight, mvNormal);

	// Add ambient and diffuse lighting
	varLightVec += vec3(0.26, 0.26, 0.26);
	varLightVec *= 1.21;
}

/*
uniform mat4 u_matViewInverse;
uniform mat4 u_matViewProjection;
uniform vec3 u_lightPosition;
uniform vec3 u_eyePosition;
varying vec2 v_texcoord;
varying vec3 v_viewDirection;
varying vec3 v_lightDirection;
attribute vec4 a_vertex;
attribute vec2 a_texcoord0;
attribute vec3 a_normal;
attribute vec3 a_binormal;
attribute vec3 a_tangent;

void main(void)
{
	// Transform eye vector into world space
	vec3 eyePositionWorld =
		(u_matViewInverse * vec4(u_eyePosition, 1.0)).xyz;
	
	// Compute world space direction vector
	vec3 viewDirectionWorld = eyePositionWorld - a_vertex.xyz;
	
	// Transform light position into world space
	vec3 lightPositionWorld =
	(u_matViewInverse * vec4(u_lightPosition, 1.0)).xyz;
	
	// Compute world space light direction vector
	vec3 lightDirectionWorld = lightPositionWorld - a_vertex.xyz;
	
	// Create the tangent matrix
	mat3 tangentMat = 
		mat3(a_tangent,
			 a_binormal,
			 a_normal);
	
	// Transform the view and light vectors into tangent space
	v_viewDirection = viewDirectionWorld * tangentMat;
	v_lightDirection = lightDirectionWorld * tangentMat;
	
	// Transform output position
	gl_Position = u_matViewProjection * a_vertex;
	
	// Pass through texture coordinate
	v_texcoord = a_texcoord0.xy;
}*/