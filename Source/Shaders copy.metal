#include <metal_stdlib>
#import "ShaderTypes.h"

using namespace metal;

typedef float2 vec2;
typedef float3 vec3;
typedef float4 vec4;

constant int MAX_ITERS = 10;  // adjust these higher for better/slower rendering
constant int MAX_STEPS = 150;

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

float dot2(vec3 z){ return dot(z,z);}

vec3 wrap(vec3 x, vec3 a, vec3 s){
    x -= s;
    return (x-a*floor(x/a)) + s;
}

vec2 wrap(vec2 x, vec2 a, vec2 s){
    x -= s;
    return (x-a*floor(x/a)) + s;
}

//void TransA(vec3 device *z, float device *DF, float a, float b) {
//    float iR = 1. / dot2(*z);
//    *z *= -iR;
//    z->x = -b - z->x;
//    z->y = a + z->y;
//    *DF *= iR;//max(1.,iR);
//}
//
//void TransAInv(device vec3 *z, device float *DF, float a, float b) {
//    float iR = 1. / dot2(*z + vec3(b,-a,0.));
//    z->x += b;
//    z->y = a - z->y;
//    *z *= iR;
//    *DF *= iR;//max(1.,iR);
//}

#define FourGen false

#define Final_Iterations 5
#define ShowBalls true // zorro false
#define DoInversion false //true

#define Clamp_y float(0.5)
#define Clamp_DF float(1)


#define Box_Iterations 25 // 30
#define box_size_z 1
#define box_size_x 1

//#define KleinR 1.90928
//#define KleinI 0.04583

#define InvCenter float3(0,1,0)
#define ReCenter float3()
#define DeltaAngle 3.07179 // 4.95674

#define InvRadius 0.38705

float  JosKleinian(vec3 z,constant Control &control)
{
    float KleinR = control.julia.x;
    float KleinI = control.julia.z;

    vec3 lz=z+vec3(1.), llz=z+vec3(-1.);
    float DE=1e10;
    float DF = 1.0;
    float a = KleinR, b = KleinI;
    float f = sign(b) ;
    

    for (int i = 0; i < Box_Iterations ; i++)
    {
        //if(z.y<0. || z.y>a) break;
        
        z.x=z.x+b/a*z.y;
        if (FourGen)
            z = wrap(z, vec3(2. * box_size_x, a, 2. * box_size_z), vec3(- box_size_x, 0., - box_size_z));
        else
            z.xz = wrap(z.xz, vec2(2. * box_size_x, 2. * box_size_z), vec2(- box_size_x, - box_size_z));
        z.x=z.x-b/a*z.y;
        
        //If above the separation line, rotate by 180∞ about (-b/2, a/2)
        if  (z.y >= a * (0.5 +  f * 0.25 * sign(z.x + b * 0.5)* (1. - exp( - 3.2 * abs(z.x + b * 0.5)))))
            z = vec3(-b, a, 0.) - z;//
        //z.xy = vec2(-b, a) - z.xy;//
        
  //zorro      orbitTrap = min(orbitTrap, abs(vec4(z,dot(z,z))));//For colouring
        
        //Apply transformation a
        //TransA(&z, &DF, a, b);
        float iR = 1. / dot2(z);
        z *= -iR;
        z.x = -b - z.x; z.y = a + z.y;
        DF *= iR;//max(1.,iR);

        
        //If the iterated points enters a 2-cycle , bail out.
        if(dot2(z-llz) < 1e-12) {
#if 0
            orbitTrap =vec4(1./float(i),0.,0.,0.);
#endif
            break;
        }
        
        //Store prÈvious iterates
        llz=lz; lz=z;
    }
    
    //WIP: Push the iterated point left or right depending on the sign of KleinI
    for (int i=0;i<Final_Iterations;i++){

        float y = ShowBalls ? min(z.y, a-z.y) : z.y;

        DE = min(DE, min(y,Clamp_y) / max(DF,Clamp_DF));
        
        //TransA(z, DF, a, b);
        float iR = 1. / dot2(z);
        z *= -iR;
        z.x = -b - z.x; z.y = a + z.y;
        DF *= iR;//max(1.,iR);

    }
    
    float y = ShowBalls ? min(z.y, a-z.y) : z.y;
    DE=min(DE,min(y,Clamp_y)/max(DF,Clamp_DF));
    
    return DE;
}

float DE    // distance estimate
(
 float3 p,
 constant Control &control)
{
    if(DoInversion){
        
        p=p-InvCenter-ReCenter;
        float r=length(p);
        float r2=r*r;
        p=(InvRadius * InvRadius/r2)*p+InvCenter;
        
        float an=atan2(p.y,p.x)+DeltaAngle;
        float ra=sqrt(p.y*p.y+p.x*p.x);
        p.x=cos(an)*ra;
        p.y=sin(an)*ra;
        float de=JosKleinian(p,control);
        de=r2*de/(InvRadius * InvRadius+r*de);
        return de;
    }
    
    else return JosKleinian(p,control);
}

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

//float DE    // distance estimate
//(
// float3 position,
// constant Control &control)
//{
//    float3 c = control.isJulia ? control.julia : position;
//    float3 v = position;
//    float dr = 1.5;
//
//    for (int i = 0; i < MAX_ITERS; i++) {
//        v = clamp(v, -control.box.x, control.box.x) * control.box.y - v;
//        if(control.isBurningShip) v = -abs(v);
//
//        float mag = dot(v, v);
//        if(mag < control.sphere.x) {
//            v = v * control.sphereMult;
//            dr = dr * control.sphereMult;
//        }
//        else if (mag < control.sphere.y) {
//            v = v / mag;
//            dr = dr / mag;
//        }
//
//        v = v * control.scaleFactor + c;
//        dr = dr * abs(control.scaleFactor) + 1.0;
//    }
//
//    return (length(v) - control.deFactor1) / dr - control.deFactor2;
//}

//MARK: -

float3 getNormal
(
 float3 position,
 constant Control &control)
{
    float ee = control.epsilon / 10;
    float4 eps = float4(0, ee, 2.0 * ee, 3.0 * ee);
    return normalize(float3(-DE(position - eps.yxx,control) + DE(position + eps.yxx,control),
                            -DE(position - eps.xyx,control) + DE(position + eps.xyx,control),
                            -DE(position - eps.xxy,control) + DE(position + eps.xxy,control)));
}

//MARK: -

float3 lighting
(
 float3 position,
 float distance,
 constant Control &control)
{
    float3 normal = getNormal(position,control);
    float3 color = normal * control.color;
    
    float3 L = normalize(control.lighting.position - position);
    float dotLN = dot(L, normal);
    if(dotLN >= 0) {
        color += control.lighting.diffuse * dotLN;
        
        float3 V = normalize(float3(distance));
        float3 R = normalize(reflect(-L, normal));
        float dotRV = dot(R, V);
        if(dotRV >= 0) color += control.lighting.specular * pow(dotRV, 2);
    }
    
//zorro    color *= (1 - distance / control.fog);
    
    return color;
}

//MARK: -

float3 rayMarch
(
 float3 rayDir,
 constant Control &control)
{
    float de,distance = 0.0;
    float3 position;

    for(;;) {
        position = control.camera + rayDir * distance;
        
        de = DE(position, control);
        if(de < control.epsilon) break;
        
        distance += de / 20;
        if(distance > control.fog * 2) return float3();
    }

    return lighting(position,distance,control);
}


//float3 rayMarch
//(
// float3 rayDir,
// constant Control &control)
//{
//    float de,distance = 0.0;
//    float3 position;
//
//    for(int i = 0; i < MAX_STEPS*15; ++i) {
//        position = control.camera + rayDir * distance;
//
//        de = DE(position, control);
//        if(de < control.epsilon) break;
//
//        distance += de / 3;
//        if(distance > control.fog * 2) return float3();
//    }
//
//    return lighting(position,distance,control);
//}


//    float3 dd = float3(1,1,1) - log(log(distance));
//    return normalize(dd); // lighting(position,distance,control);

//MARK: -

kernel void mandelBoxShader
(
 texture2d<float, access::write> outTexture [[texture(0)]],
 constant Control &control [[buffer(0)]],
 uint2 p [[thread_position_in_grid]])
{
    if(p.x > uint(control.xSize) || p.y > uint(control.ySize)) return;
    
    float den = float(control.xSize);
    float dx =  control.zoom * (float(p.x)/den - 0.5);
    float dy = -control.zoom * (float(p.y)/den - 0.5);
    
    float3 direction = normalize((control.sideVector * dx) + (control.topVector * dy) + control.viewVector);
    
    outTexture.write(float4(rayMarch(direction,control),1),p);
}
