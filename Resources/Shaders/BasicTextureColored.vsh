attribute highp vec3 attrVertexCoord;
attribute highp vec2 attrTexCoord;

uniform highp mat4 uniMatrixProjModelView;

varying mediump vec2 varTexCoord;

// A very simple texture shader, but with ability to control the rgba of each pixel
// Avoid using it for full screen textures, as we do vec mult on each pixel
void main()
{
	gl_Position = uniMatrixProjModelView * vec4(attrVertexCoord, 1.0);
	varTexCoord = attrTexCoord;
}
