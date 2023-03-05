#iChannel0 "file://bufferB.glsl"
#include "common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4(texelFetch(iChannel0, ivec2(fragCoord.xy), 0).xyz, 1.0);
}