#include "common.glsl"
#iChannel1 "B.glsl"

void mainImage(out vec4 O, in vec2 U) {vec4 b=B; O=vec4(b.xy, (b.z+b.w),1.);}

