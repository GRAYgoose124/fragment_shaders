#define SCALE(v, mx, a, b) (a + (v * (b - a) / mx))
vec2 scale(vec2 mn, vec2 mx, mat2 bounds) {
    return vec2(SCALE(mn.x, mx.x, bounds[0][0], bounds[0][1]),
                SCALE(mn.y, mx.y, bounds[1][0], bounds[1][1]));
}

vec3 hueShift(vec3 color, float hue) {
    const vec3 k = vec3(0.57735, 0.57735, 0.57735);
    float cosAngle = cos(hue);
    return vec3(color * cosAngle + cross(k, color) * sin(hue) + k * dot(k, color) * (1.0 - cosAngle));
}

vec2 wrap(in vec2 p, in vec2 res) {
    if (p.x > res.x) p.x = mod(p.x, res.x);
    else if (p.x < 0.) p.x = res.x + p.x;

    if (p.y > res.y) p.y = mod(p.y, res.y);
    else if (p.y < 0.) p.y = res.y + p.y;

    return p;
}


float hash(float n){ return fract(sin(n)*136.5453123); }

float c_magsqrd(vec2 c) {
    return c.x * c.x + c.y * c.y;
}

vec2 c_conj(vec2 c) {
  return vec2(c.x, -c.y);
}

vec2 c_recip(vec2 z){
    float div_r = 1. / c_magsqrd(z);
    vec2 result = c_conj(z) * div_r;
    return result;
}

// screen / drawing
vec3 draw_point(inout vec3 col, vec2 pos, vec2 pt, float r){
    return c_magsqrd(pos - pt) < r ? vec3(1) : col;
}
