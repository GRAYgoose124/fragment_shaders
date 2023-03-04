#iChannel0 "file://bufferB.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 ab = fragCoord.xy / iResolution.xy;
    fragColor = texelFetch(iChannel0, ivec2(ab.xy), 0)*cos(iTime);
}