#iChannel0 "file://bufferB.glsl"
#include "common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = hueShift(pF(iChannel0).xyz, sin(iTime));
}