#iChannel0 "file://bufferA.glsl"
#iChannel1 "file://bufferC.glsl"
#include "common.glsl"

#define STRENGTH 100.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = pF(iChannel1);
}

