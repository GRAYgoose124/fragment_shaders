#include "common.glsl"
#iChannel0 "bufA.glsl"


void mainImage(out vec4 O,in vec2 Q){O=A(SS(Q));}
