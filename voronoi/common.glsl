float cms(vec2 c) { 
    return c.x * c.x + c.y * c.y; 
}

vec3 draw_point(vec3 col, vec2 pos, vec2 pt, float r){
    return cms(pos - pt) < r ? vec3(1) : col;
}

float scale(float v, float mx, float a, float b) {
    return a + (v * (b - a) / mx);
}

vec2 scale(vec2 v, float mx, float a, float b){
    return vec2(scale(v.x, mx, a, b), scale(v.y, mx, a, b));
}

float rand(int seed){
    return fract(sin(float(seed) * 78.233) * 43758.5453);
}