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

varying lowp    vec3 varLightVec;
varying mediump vec2 varTexCoord;
varying mediump vec2 varEnvMap;

// A shader that implements Normal Mapping and Reflection Mapping effects together.
void main()
{
	gl_Position = uniMatrixProjModelView * vec4(attrVertexCoord, 1.0);
	varTexCoord = attrTexCoord;

	// Tangent, vertex and normal to eye space
	vec3 mvTangent = normalize(uniMatrixModelViewIT * attrTanCoord);
	vec3 mvNormal = normalize(uniMatrixModelViewIT * attrNormalCoord);
	vec3 mvBitangent = cross(mvNormal, mvTangent);
	vec3 mvVertex = vec3(uniMatrixModelView * vec4(attrVertexCoord, 1.0));

	// Calculate light direction and actual light vector
	vec3 mvDirToLight = normalize(uniLightPos - mvVertex);
    varLightVec.x = dot(mvDirToLight, mvTangent);
	varLightVec.y = dot(mvDirToLight, mvBitangent);
	varLightVec.z = dot(mvDirToLight, mvNormal);

	// Add ambient and diffuse lighting
	varLightVec += vec3(0.26, 0.26, 0.26);
	varLightVec *= 1.21;

	// Calculate coords for reflection map
	varEnvMap = reflect(mvDirToLight, mvNormal).xy * 0.25 + 0.5;
}
