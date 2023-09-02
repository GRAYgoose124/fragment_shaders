// Shadertoy Common
#define R iResolution
#define T (iTime)


// math scale screen space and center
#define SS(p) (p.xy / R.xy * 2.0 - 1.0)

#define A(U) texture(iChannel0, U)
#define B(U) texture(iChannel1, U)
#define C(U) texture(iChannel2, U)
#define D(U) texture(iChannel2, U)

// Math Common
#define PI 3.14159265


// Matrix Ops
#define projectX mat2(1.0, 0.0, 0.0, 0.0)
#define projectY mat2(0.0, 0.0, 0.0, 1.0)
#define projectXY mat2(0.0, 0.0, 0.0, 0.0)
#define projectYX mat2(0.0, 0.0, 1.0, 0.0)

#define reflectX mat2(-1.0, 0.0, 0.0, 1.0)
#define reflectY mat2(1.0, 0.0, 0.0, -1.0)
#define reflectXY mat2(0.0, 1.0, 1.0, 0.0)
#define reflectYX mat2(0.0, -1.0, -1.0, 0.0)

#define translate(v) mat2(1.0, 0.0, v.x, v.y)
#define translateX(x) mat2(1.0, 0.0, x, 0.0)
#define translateY(y) mat2(1.0, 0.0, 0.0, y)
#define translateXY(x, y) mat2(1.0, 0.0, x, y)

#define tilt(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define tiltX(a) mat2(1.0, 0.0, 0.0, cos(a), -sin(a), 0.0, sin(a), cos(a))
#define tiltY(a) mat2(cos(a), 0.0, sin(a), 0.0, 1.0, 0.0, -sin(a), 0.0, cos(a))
#define tilt90 mat2(0.0, -1.0, 1.0, 0.0)
#define tilt180 mat2(-1.0, 0.0, 0.0, -1.0)
#define tilt270 mat2(0.0, 1.0, -1.0, 0.0)

#define rotate(a) mat2(cos(a), -sin(a), sin(a), cos(a))
#define rotateX(a) mat2(1.0, 0.0, 0.0, cos(a), -sin(a), 0.0, sin(a), cos(a))
#define rotateY(a) mat2(cos(a), 0.0, sin(a), 0.0, 1.0, 0.0, -sin(a), 0.0, cos(a))
#define rotate90 mat2(0.0, -1.0, 1.0, 0.0)
#define rotate180 mat2(-1.0, 0.0, 0.0, -1.0)
#define rotate270 mat2(0.0, 1.0, -1.0, 0.0)

#define flip(a) mat2(cos(a), sin(a), -sin(a), cos(a))
#define flipX mat2(-1.0, 0.0, 0.0, 1.0)
#define flipY mat2(1.0, 0.0, 0.0, -1.0)
#define flipXY mat2(0.0, 1.0, 1.0, 0.0)
#define flipYX mat2(0.0, -1.0, -1.0, 0.0)

#define scale(s) mat2(s, 0.0, 0.0, s)
#define scalexy(sx, sy) mat2(sx, 0.0, 0.0, sy)
#define shearX(s) mat2(1.0, s, 0.0, 1.0)
#define shearY(s) mat2(1.0, 0.0, s, 1.0)
#define shearXY(sx, sy) mat2(1.0, sy, sx, 1.0)

#define stretch(s) mat2(s, 0.0, 0.0, 1.0/s)
#define stretchX(s) mat2(s, 0.0, 0.0, 1.0)
#define stretchY(s) mat2(1.0, 0.0, 0.0, s)
#define stretchXY(sx, sy) mat2(sx, 0.0, 0.0, sy)

#define squash(s) mat2(1.0/s, 0.0, 0.0, s)
#define squashX(s) mat2(1.0/s, 0.0, 0.0, 1.0)
#define squashY(s) mat2(1.0, 0.0, 0.0, s)
#define squashXY(sx, sy) mat2(1.0/sx, 0.0, 0.0, sy)

#define swirl(a) mat2(cos(a), sin(a), sin(a), cos(a))
#define twist(a, t) mat2(cos(a+t), -sin(a+t), sin(a-t), cos(a-t))
#define warp(a, s, t) mat2(cos(a+s), sin(a+s), sin(a+t), cos(a+t))
#define auger(a, s) mat2(cos(a), sin(a), sin(a+s), cos(a))
#define barycentric(a, s) mat2(cos(a), sin(a), sin(a+s), cos(a+s))

#define barycentricScale(a, s, sx, sy) mat2(cos(a)*sx, sin(a)*sx, sin(a+s)*sy, cos(a+s)*sy)

#define twistScale(a, t, sx, sy) mat2(cos(a+t)*sx, -sin(a+t)*sy, sin(a-t)*sx, cos(a-t)*sy)
#define warpShear(a, s, t, ax, ay) mat2(cos(a+s+ax), sin(a+s+ax), sin(a+t+ay), cos(a+t+ay))

#define skewShearX(s, ax, ay) mat2(1.0, s+ax, s+ay, 1.0)
#define skewShearY(s, ax, ay) mat2(1.0, s+ay, s+ax, 1.0)

#define stretchShearX(s, ax, ay) mat2(1.0/s, s+ax, 0.0, 1.0)
#define stretchShearY(s, ax, ay) mat2(1.0, 0.0, s+ay, 1.0/s)


// Functions
float rand(float s){
    return fract(sin(s) * 31758.1453);
}
