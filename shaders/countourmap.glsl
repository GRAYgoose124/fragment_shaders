#define S(v)  smoothstep( 1.5,-1., (v+z)/fwidth(z) )


void mainImage( out vec4 O, vec2 U )
{
    U = 5. * ( U / iResolution.xy - .5 );
    float r = dot(U, U),
          k = 2.*cos(0.5*iTime),
          a = pow(r, k), z, s;
    U *= a;

    z = mix( sin(U*U.x) * cos(U*U.y),
             sin(U*U.y) * cos(U*U.x),
                    0.1*cos(iTime) ).x;
    s = 2.*sin(iTime);
           
    O = vec4( 3.*S(-.5) - S() + 2.*S(.5 * s) ) / 4.   
              * ( 1. -  ( S( -.5 * s ) - S( +.5 ) ) 
              * smoothstep(-1., 1., s) 
             );
}