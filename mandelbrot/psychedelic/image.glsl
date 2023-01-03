#iChannel0 "file://bufferB.glsl"
precision highp float;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = texelFetch(iChannel0, ivec2(fragCoord.xy),0);
} 