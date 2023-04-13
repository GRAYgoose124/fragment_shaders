#iChannel0 "file://bufferA.glsl"
#define PI 3.14159265359
#define TAU 6.283185307179586
#define MAX_ITERS 150.
#define SPHERE_EPS .00001

vec3 sphereMapping(vec3 dir) {
  float t_off = 0.01*cos(iTime*0.15);
  vec2 uv = vec2(atan(dir.z, dir.x+t_off), asin(dir.y));
  uv /= TAU;
  uv += .5;
  
  float t = iTime * 0.5;
  vec2 c = vec2(-cos(t) * cos(t), sin(t) * cos(t));

  vec2 z = vec2(0.0, 0.0);
  float iter;
  for (iter=0.; iter < MAX_ITERS; iter++) {
    vec2 newZ = dot(z, z) + c;
    if (dot(newZ, newZ) > 4.0) break;
    z = newZ;
  }

  float displacement = iter / float(MAX_ITERS);
  vec3 normal = normalize(dir);
  vec3 perturbation = displacement * normal;
  
  float maxDisplacement = .01 * length(normal);
  perturbation *= min(0.0, maxDisplacement / length(perturbation));
  
  return texture(iChannel0, uv).rgb + perturbation;
}

void mainImage(out vec4 O, in vec2 U) {
  vec2 z = ( 2.0 * U - iResolution.xy ) / iResolution.y;
  
  float t = iTime * 0.5;
  vec2 c = vec2(-cos(t) * cos(t), sin(t) * cos(t));
  
  vec3 rayDir = normalize(vec3(z, -1.0));
  vec3 rayPos = vec3(0.0, 0.0, 1.25);
  

  float dist = 0.0;
  vec3 color = vec3(0.0);
  for (int i = 0; i < 100; i++) {
    vec3 pos = rayPos + dist * rayDir;
    vec3 normal = normalize(pos);
    float d = length(pos) - 1.0 + 0.2 * length(sphereMapping(normal));    
    if (d < SPHERE_EPS) {
      color = sphereMapping(normal);
    }
    dist += d;
    if (dist > 10.0) break;
  }

  O = vec4(color, 1.0);
}