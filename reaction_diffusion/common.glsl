// Uncomment for mouse parameterizing of D-R:
//#define MOUSE

// mainImage helpers 
#define p fragCoord.xy
#define res iResolution.xy
#define uv (p / res)
#define muv (iMouse.xy / res)

// Math Util
float cms(vec2 c) { 
    return c.x * c.x + c.y * c.y; 
}

float norm(float value, float rmin, float rmax, float tmin, float tmax) {
    return ((value - rmin) / (rmax - rmin)) * (tmax - tmin) + tmin;
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}


// Screen
#define AREA_CLICKED(r) (cms(iMouse.xy - fragCoord.xy) < r) && sign(iMouse.z) == 1.

vec2 wrap(in vec2 pos, vec2 maxres) {
    if (pos.x > maxres.x) {
        pos.x = mod(pos.x, maxres.x);
    } else if (pos.x < 0.) {
        pos.x = maxres.x + pos.x;
    }
    if (pos.y > maxres.y) {
        pos.y = mod(pos.y, maxres.y);
    } else if (pos.y < 0.) {
        pos.y = maxres.y + pos.y;
    }
    
    return pos;
}

void draw_point(inout vec4 col, vec2 pos, vec2 pt, float r){
    col = cms(pos - pt) < r ? vec4(1., 1., 1., 0.) : col;
}