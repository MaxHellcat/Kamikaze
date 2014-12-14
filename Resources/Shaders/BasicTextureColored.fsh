uniform sampler2D texUnit0;
uniform lowp vec4 uniLightColor;

varying mediump vec2 varTexCoord;

void main()
{
	gl_FragColor = texture2D(texUnit0, varTexCoord) * uniLightColor;
}
