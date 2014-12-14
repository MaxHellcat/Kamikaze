// reUse Lighting spotted and get rid of this shader
uniform sampler2D sTexture;

varying lowp    float LightIntensity;
varying mediump vec2  TexCoord;

void main()
{
    gl_FragColor = texture2D(sTexture, TexCoord) * LightIntensity;
}
