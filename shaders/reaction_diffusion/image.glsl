#iChannel0 "file://bufferD.glsl"

// See Common for D-R configuration.
// All buffers are just extra passes of D-R.

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec3 surface = texelFetch(iChannel0, ivec2(fragCoord.xy), 0).xyz;

    vec3 col = surface.xyz;
    fragColor = vec4(col, 1.);
}