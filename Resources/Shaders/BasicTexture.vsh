attribute highp vec3 attrVertexCoord;
attribute highp vec2 attrTexCoord;

uniform highp mat4 uniMatrixProjModelView;

varying mediump vec2 varTexCoord;

// A very simple texture shader, no effects. Use it to draw textured primitives
void main()
{
	gl_Position = uniMatrixProjModelView * vec4(attrVertexCoord, 1.0);
	varTexCoord = attrTexCoord;
}
