#iChannel0 "self"

#define TAU 6.2831853
#define MAX_STEPS 128
#define MAX_DIST 100.0
#define EPSILON 0.0001

float sphereSDF(vec3 pos, float r) {
    return length(pos) - r;
}

// Draws a single sphereSDF along a fiber knot
float hopfFibrationSDF(vec3 pos, float offset) {
    float t = TAU * iTime * 0.1;
    float c = cos(t + offset);
    float s = sin(t + offset);

    float r1 = sqrt(dot(pos.xy, pos.xy) + pos.z * pos.z);
    float r2 = sqrt(dot(pos.xz, pos.xz) + pos.y * pos.y);
    float x1 = pos.x * c + pos.y * s;
    float y1 = -pos.x * s + pos.y * c;
    float z1 = pos.z;

    float a = r2 * c + r1 * s;
    float b = r2 * s - r1 * c;
    float x2 = a * cos(t) - b * sin(t);
    float y2 = b * cos(t) + a * sin(t);
    float z2 = pos.z;

    vec3 q = vec3(x2, y2, z2);
    float phi = atan(q.y, q.x);
    float theta = acos(q.z / length(q));
    float r3 = sin(2.0 * theta) * (2.0 + cos(2.0 * phi + t));
    vec3 h = vec3(
        r3 * cos(phi),
        r3 * sin(phi),
        cos(2.0 * theta) * sin(2.0 * phi + t)
    );
    float r = 0.5;
    return sphereSDF(pos - h, r);
}

// Draw the entire knot as a union of hopfFibrationSDFs
float knotSDF(vec3 pos, float offset) {
    float d = 10.0;
    float t = 0.0;
    float step = 0.01;
    for (int i = 0; i < 50; i++) {
        float dist = hopfFibrationSDF(pos, float(i) * TAU / 50.0 + offset);
        d = min(d, dist);
        t += step;
    }
    return d;
}

float trace(vec3 origin, vec3 direction, float offset) {
    float dist = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 pos = origin + dist * direction;
        float d = knotSDF(pos, offset);
        if (d < EPSILON) {
            return dist;
        }
        dist += d;
        if (dist >= MAX_DIST) {
            return -1.0;
        }
    }
}

vec3 hsv2rgb(vec3 hsv) {
    vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(hsv.xxx + k.xyz) * 6.0 - k.www);
    return hsv.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), hsv.y);
}

vec3 getColorForStep(float step) {
    float hue = mod(iTime * 0.1 + step * 0.1, 1.0);
    return hsv2rgb(vec3(hue, 1.0, 1.0));
}

vec3 pathTrace(vec3 origin, vec3 direction) {
    vec3 color = vec3(0.0);
    vec3 attenuation = vec3(1.0);
    
    int i = 0;

    float dist = trace(origin, direction, float(i));
    if (dist < 0.0) {
        return color;
    }
    
    vec3 pos = origin + dist * direction;
    vec3 normal = normalize(vec3(
        trace(pos, vec3(1.0, -EPSILON, 0.0), float(i)) - trace(pos, vec3(-1.0, -EPSILON, 0.0), float(i)),
        trace(pos, vec3(0.0, 1.0, 0.0), float(i)) - trace(pos, vec3(0.0, -1.0, 0.0), float(i)),
        trace(pos, vec3(0.0, 0.0, 1.0), float(i)) - trace(pos, vec3(0.0, 0.0, -1.0), float(i))
    ));

    vec3 newOrigin = pos + EPSILON * normal;
    vec3 newDirection = normalize(reflect(direction,  normal));
    color += attenuation * getColorForStep(float(i));
    attenuation *= vec3(0.5);
    origin = newOrigin;
    direction = newDirection;
    
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    vec3 origin = vec3(0.0, 0.0, -4.0);
    vec3 direction = normalize(vec3(uv, 1.0));
    vec3 currentColor = pathTrace(origin, direction);

    // Average the current color with the color from the previous frame
    // vec4 prevColor = texture(iChannel0, fragCoord.xy);
    // vec3 afterImageColor = (currentColor + prevColor.rgb) * 0.5;

    // Write the after image color to the output color
    fragColor = vec4(currentColor, 0.0);
}
