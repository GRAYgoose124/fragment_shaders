#iChannel0 "file://bufferA.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = fragCoord.xy/iResolution.xy;

    vec3 surface = texelFetch(iChannel0, ivec2(fragCoord.xy), 0).xyz;

    vec3 col = surface.xyz;
    fragColor = vec4(col, 1.);
}