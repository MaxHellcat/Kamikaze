//
//  Shader.fsh
//  Kamikaze
//
//  Created by Hellcat on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

uniform sampler2D texUnit0;

//uniform lowp float spiritness;

varying mediump vec2 varTexCoord;
varying lowp    vec4 varDiffuseLight;

void main()
{
	gl_FragColor = texture2D(texUnit0, varTexCoord) * varDiffuseLight;

// Motion blur
//	lowp vec3 color = texColor * varDiffuseLight;
//	gl_FragColor = vec4(color, spiritness * spiritness) * 3.0;
}
