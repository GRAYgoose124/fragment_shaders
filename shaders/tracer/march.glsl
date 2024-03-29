#include "all.glsl"

const vec3 DIFFUSE_COLOR=vec3(1.,.7,.5);
const vec3 SPECULAR_COLOR=vec3(1.,1.,1.);

const vec3 lightColor=vec3(1.,1.,1.);
const vec3 lightPos=vec3(1000.,10.,-20.);
const float lightIntensity=.8;

#define SCENE_ROTATE
float sceneSDF(vec3 p){
    #ifdef SCENE_ROTATE
    if(iMouse.z<0.){
        p=rotateX(p,iTime*.1);
        p=rotateY(p,iTime*.1);
        p=rotateZ(p,iTime*.1);
    }
    else{
        p=rotateX(p,iMouse.x*.01);
        p=rotateY(p,iMouse.y*.01);
        p=rotateZ(p,iMouse.x*.01);
    }
    #endif
    
    // Build scene here.
    float d=icosahedronSDF(p,1.);
    return d;
}

#define SURFACE_DISTANCE.01
vec3 estimateNormal(vec3 p,float d){
    vec3 n=vec3(
        d-sceneSDF(vec3(p.x+SURFACE_DISTANCE,p.y,p.z)),
        d-sceneSDF(vec3(p.x,p.y+SURFACE_DISTANCE,p.z)),
        d-sceneSDF(vec3(p.x,p.y,p.z+SURFACE_DISTANCE))
    );
    return-normalize(n);
}

#define MAX_STEPS 256
#define MAX_DISTANCE 2500.
#define MAX_BOUNCES 3
#define SHADOW_DISTANCE 1.
#define ATTENUATE_FACTOR.75
vec3 traceRay(vec3 ro,vec3 rd){
    float t=0.;
    vec3 accumulatedColor=vec3(0.);
    vec3 attenuation=vec3(1.);
    
    for(int i=0;i<MAX_STEPS;i++){
        vec3 pos=ro+t*rd;
        float dist=sceneSDF(pos);
        
        if(dist<SURFACE_DISTANCE){
            vec3 normal=estimateNormal(pos,dist);
            
            for(int bounces=0;bounces<MAX_BOUNCES;bounces++){
                float shadowFactor=1.;
                vec3 toLight=normalize(lightPos-pos);
                vec3 shadowRayOrigin=pos+SHADOW_DISTANCE*toLight;
                float shadowT=0.;
                
                for(int j=0;j<4;j++){
                    vec3 shadowPos=shadowRayOrigin+shadowT*toLight;
                    float shadowDist=sceneSDF(shadowPos);
                    if(shadowDist<.001){// Using a small threshold instead of SHADOW_DISTANCE
                        shadowFactor=0.;
                        break;
                    }
                    shadowT+=shadowDist;
                    if(shadowT>MAX_DISTANCE||shadowFactor==0.)break;// Exit if shadow is determined or max distance is reached
                }
                
                float diffuse=max(dot(-normal,toLight),0.);
                float specular=pow(max(dot(reflect(toLight,-normal),-rd),0.),8.);
                
                vec3 localColor=
                ((vec3(diffuse*lightIntensity)*DIFFUSE_COLOR*lightColor)+
                (specular*SPECULAR_COLOR*lightColor))*shadowFactor;
                
                accumulatedColor+=attenuation*localColor;
                
                ro=pos+SURFACE_DISTANCE*normal;
                rd=reflect(rd,normal);
                attenuation*=ATTENUATE_FACTOR;
                
                t=0.;
                bool hitSurface=false;
                for(int j=0;j<MAX_STEPS;j++){
                    pos=ro+t*rd;
                    dist=sceneSDF(pos);
                    if(dist<SURFACE_DISTANCE){
                        hitSurface=true;
                        break;
                    }
                    t+=dist;
                    if(t>MAX_DISTANCE)break;
                }
                
                if(!hitSurface)break;
            }
            return accumulatedColor;
        }
        
        t+=dist;
        if(t>MAX_DISTANCE)break;
    }
    
    return accumulatedColor;
}
