// Note: In case you change the variable names below, remember to always update corresponding
// names in Shader class

// Carefully mind in the code, which sampler corresponds to which texture unit
uniform sampler2D texUnit0; // Diffuse map
uniform sampler2D texUnit1; // Normal map
uniform sampler2D texUnit2; // Reflect map

uniform mediump float uniAlpha;

varying lowp    vec3 varLightVec;
varying mediump vec2 varTexCoord;
varying mediump	vec2 varEnvMap;

void main()
{
	// Read texture maps
	lowp vec3 texColor  = texture2D(texUnit0, varTexCoord).rgb;
	lowp vec3 normal = texture2D(texUnit1, varTexCoord).rgb * 2.0 - 1.0;
	lowp vec3 envColour = texture2D(texUnit2, varEnvMap).rgb;

	// Calculate light intensity in this dot, ready for normal mapping
	lowp float lightIntensity = dot(normal, varLightVec);

	// Because lightIntensity lies in [0.. ~1.6) we need to decrease it
	lowp float declevel = 0.60;
//	lowp float declevel = 0.4;

	/*
	 Result of this command depends on the value of (lightIntensity - declevel):
	 near 1:     reflection goes as it is
	 near 0.8:   reflection decreased twice
	 near 0.6:   reflection decreases six times
	 near 0:     no reflection
	 lower zero: not recommended

	 Here we're decreasing reflection effect to stop overlighting bump-map
	 */
	lowp vec3 summaryReflection = envColour * (lightIntensity - declevel) * (lightIntensity - declevel); 

	// Analytic formula: tex * (1 - ref) + ref
	// Texture is "burned" with reflection by '* (1 - ref)'
	gl_FragColor = vec4(texColor * lightIntensity * (1.0 - summaryReflection) + summaryReflection, uniAlpha);
}
