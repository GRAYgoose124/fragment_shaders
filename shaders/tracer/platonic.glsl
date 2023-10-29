#ifndef PLATONIC_H
#define PLATONIC_H
#include "sdf.glsl"

#define phi 1.618
const vec3 icosahedron[12]=vec3[](
    vec3(-1.,phi,0.),
    vec3(1.,phi,0.),
    vec3(-1.,-phi,0.),
    vec3(1.,-phi,0.),
    
    vec3(0.,-1.,phi),
    vec3(0.,1.,phi),
    vec3(0.,-1.,-phi),
    vec3(0.,1.,-phi),
    
    vec3(phi,0.,-1.),
    vec3(phi,0.,1.),
    vec3(-phi,0.,-1.),
    vec3(-phi,0.,1.)
);

float icosahedronSDF(vec3 p,float scale){
    const float INF=1e10;
    float d=INF;
    vec3 scaledIcoVert,scaledIcoEdge;
    
    for(int i=0;i<12;i++){
        scaledIcoVert=2.*scale*icosahedron[i];// Scaling factor for vertices
        
        // Vertices
        d=min(d,sphereSDF(p,scaledIcoVert,1.));
        
        for(int j=i+1;j<12;j++){
            scaledIcoEdge=2.*scale*icosahedron[j];// Scaling factor for edges
            
            // Edges
            d=min(d,cylinderSDF(p,scaledIcoVert,scaledIcoEdge,.1));
        }
        
        // Faces
        // if(i%2==0){
            //     d=min(d,triangleSDF(p,scaledIcoVert,2.*scale*icosahedron[i+1],2.*scale*icosahedron[(i+2)%12]));
        // }
    }
    
    return d;
}

#endif