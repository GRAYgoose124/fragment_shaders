#define PI 3.14159265359
#define MAX_ITERS 150

void mainImage(out vec4 O, in vec2 U) {
  vec2 z = ( 2.*U - iResolution.xy ) / iResolution.y;
  
  float t = iTime * .2;
  
  vec2 c = vec2(-cos(t)*cos(t), sin(t)*cos(t));
  
  O = vec4(0);
  int i=0;
  for (; i < MAX_ITERS && dot(z,z) < 4.; i++) 
    z = mat2(z,-z.y,z.x) * z + c;
  
  if (i < MAX_ITERS) {
    float t = float(i)/float(MAX_ITERS);
    vec3 color = vec3(t-z.x, cos(z.y-c.x)*sin(z.x-c.y), t+z.y);
    color = 0.5 + 0.5*sin(PI*(color-t));
    O = vec4(color, 1.0);
  }
}
