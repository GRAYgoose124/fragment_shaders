#define SCALING 10.
#define SPEED 100.

#define T ((iTime / 100.) * SPEED)


void iterator(in vec2 uv, inout vec4 col) {
    float r = dot(sin(col.y*uv), cos(col.z*uv*-sin(T)));
    float g = r*dot(cos(col.x*uv), sin(col.z*uv*sin(T)));
    float b = g*dot(sin(col.x*uv), cos(col.y*uv*cos(T)));
    r = b*r;

    col = vec4(r, g, b, 1.0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = fragCoord.xy / SCALING;
    
    vec4 col = fragColor;
    for (int i = 0; i < 10; i++) {
        iterator(uv, col);
    }
    
    fragColor = vec4(col.xyz, 1.0);
}