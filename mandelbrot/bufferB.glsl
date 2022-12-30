#iChannel0 "file://bufferA.glsl"
#iChannel1 "file://bufferB.glsl"
#include "common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 C0 = texelFetch(iChannel0, ivec2(fragCoord.xy), 0);
    vec4 C1 = texelFetch(iChannel1, ivec2(fragCoord.xy), 0);
    vec4 L0 = filter3x3(fragCoord.xy, LAPLACIAN, iChannel0, iResolution.xy);
    vec4 G1 = filter3x3(fragCoord.xy, GAUSSIAN, iChannel1, iResolution.xy);
    
    fragColor = sobel(fragCoord.xy, iChannel0, iResolution.xy);

    fragColor *= -L0 / (2.-C0);
    
    fragColor += C1 + G1;
    fragColor *= 0.49;
    fragColor += -L0 / (2.-C1);

    
    fragColor += G1 + L0;
    fragColor *= 0.49;
    fragColor -= C0 + G1;

}