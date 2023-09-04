// Utils
vec3 rotateX(vec3 p, float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return vec3(p.x, c*p.y - s*p.z, s*p.y + c*p.z);
}

vec3 rotateY(vec3 p, float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return vec3(c*p.x - s*p.z, p.y, s*p.x + c*p.z);
}

vec3 rotateZ(vec3 p, float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return vec3(c*p.x - s*p.y, s*p.x + c*p.y, p.z);
}