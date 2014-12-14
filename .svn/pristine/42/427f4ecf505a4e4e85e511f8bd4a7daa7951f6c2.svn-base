precision mediump float;

uniform sampler2D sTexture;
//uniform float uParticleShape;

varying vec2  vTexCoord;
varying float vColor;

void main(void)
{
	gl_FragColor = texture2D(sTexture, gl_PointCoord);
	if (gl_FragColor.a < 0.2) discard;
//	if (gl_FragColor.r + gl_FragColor.b + gl_FragColor.g < 0.2 || vColor < 0.0) discard;
}