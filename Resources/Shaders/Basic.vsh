attribute highp vec3 attrVertexCoord;

uniform highp mat4 uniMatrixProjModelView;

// A very simple shader, no effects. Use it to draw untextured primitives
void main()
{
	gl_Position = uniMatrixProjModelView * vec4(attrVertexCoord, 1.0);
}
