//
//  Shader.fsh
//  Kamikaze
//
//  Created by Hellcat on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

uniform sampler2D texUnit0;

varying mediump vec2 varTexCoord;
varying lowp	vec4 varDiffuseLight;

void main()
{
	gl_FragColor = texture2D(texUnit0, varTexCoord) * varDiffuseLight;
}
