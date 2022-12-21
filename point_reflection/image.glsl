#define T iTime
#define Tc cos(T)
#define Ts sin(T)
#define Tcs Tc*Ts


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = (fragCoord/iResolution.xy);
    
    uv -= vec2(.5, 0.5);
    uv *= 3.5;

    vec2 roots[3] = vec2[3](vec2(    0.5,     0.),
                            vec2(Ts*-.5, Tc* 1.),
                            vec2(Tc* .5, Ts*-1.));
    
    vec3 col = vec3(1.);
    
    vec2 z = uv;
    float dist = 1.;
    float d = 0.;
    for(int i=0;i<3;i++){
        d = length(z - roots[i]) - d;
        if (d < dist){
            z = (z - (roots[i])) * (d/dist);
            //z -= (z.xy*d/dist)/(z.yx-dist)*(d);
            z *= length(z);
            dist = d;
            col += vec3(z, z.y+z.x);
        }
    }
  ;
    
    // Output to screen
    fragColor = vec4(col-vec3(1.), 1.);
}