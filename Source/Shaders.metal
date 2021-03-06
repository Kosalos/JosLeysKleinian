#include <metal_stdlib>
#import "ShaderTypes.h"

using namespace metal;

typedef float2 vec2;
typedef float3 vec3;
typedef float4 vec4;

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

float  JosKleinian(vec3 z,constant Control &control)
{
    vec3 lz=z+vec3(1.), llz=z+vec3(-1.);
    float DE=1e10;
    float DF = 1.0;
    float a = control.KleinR;
    float b = control.KleinI;
    float f = sign(b);

    for (int i = 0; i < control.Box_Iterations ; i++)
    {
        //if(z.y<0. || z.y>a) break;
        
        z.x=z.x+b/a*z.y;
        if (control.fourGen)
            z = wrap(z, vec3(2. * control.box_size_x, a, 2. * control.box_size_z), vec3(- control.box_size_x, 0., - control.box_size_z));
        else
            z.xz = wrap(z.xz, vec2(2. * control.box_size_x, 2. * control.box_size_z), vec2(- control.box_size_x, - control.box_size_z));
        z.x=z.x-b/a*z.y;
        
        //If above the separation line, rotate by 180∞ about (-b/2, a/2)
        if  (z.y >= a * (0.5 +  f * 0.25 * sign(z.x + b * 0.5)* (1. - exp( - 3.2 * abs(z.x + b * 0.5)))))
            z = vec3(-b, a, 0.) - z;//
        //z.xy = vec2(-b, a) - z.xy;//
        
        //Apply transformation a
        //TransA(&z, &DF, a, b);
        float iR = 1. / dot2(z);
        z *= -iR;
        z.x = -b - z.x; z.y = a + z.y;
        DF *= iR;//max(1.,iR);

        //If the iterated points enters a 2-cycle , bail out.
        if(dot2(z-llz) < 1e-12) {
            break;
        }
        
        //Store prÈvious iterates
        llz=lz; lz=z;
    }
    
    //WIP: Push the iterated point left or right depending on the sign of KleinI
    for (int i=0;i<control.Final_Iterations;i++){

        float y = control.showBalls ? min(z.y, a-z.y) : z.y;

        DE = min(DE, min(y,control.Clamp_y) / max(DF,control.Clamp_DF));
        
        //TransA(z, DF, a, b);
        float iR = 1. / dot2(z);
        z *= -iR;
        z.x = -b - z.x; z.y = a + z.y;
        DF *= iR;//max(1.,iR);

    }
    
    float y = control.showBalls ? min(z.y, a-z.y) : z.y;
    DE=min(DE,min(y,control.Clamp_y)/max(DF,control.Clamp_DF));
    
    return DE;
}

float DE    // distance estimate
(
 float3 p,
 constant Control &control)
{
    if(control.doInversion){
        
        p=p-control.InvCenter-control.ReCenter;
        float r=length(p);
        float r2=r*r;
        p=(control.InvRadius * control.InvRadius/r2)*p+control.InvCenter;
        
        float an=atan2(p.y,p.x)+control.DeltaAngle;
        float ra=sqrt(p.y*p.y+p.x*p.x);
        p.x=cos(an)*ra;
        p.y=sin(an)*ra;
        float de=JosKleinian(p,control);
        de=r2*de/(control.InvRadius * control.InvRadius+r*de);
        return de;
    }
    
    else return JosKleinian(p,control);
}

//MARK: -

float3 getNormal
(
 float3 position,
 constant Control &control)
{
    float ee = control.normalEpsilon/10;
    float4 eps = float4(0, ee, 2.0 * ee, 3.0 * ee);
    return normalize(float3(-DE(position - eps.yxx,control) + DE(position + eps.yxx,control),
                            -DE(position - eps.xyx,control) + DE(position + eps.xyx,control),
                            -DE(position - eps.xxy,control) + DE(position + eps.xxy,control)));
}

//MARK: -

float3 lighting
(
 float3 position,
 float  distance,
 float3 normal,
 constant Control &control)
{
    float3 color = normal * control.color;
    
    float3 L = normalize(control.lighting.position - position);
    float dotLN = dot(L, normal);
    if(dotLN >= 0) {
        color += control.lighting.diffuse * dotLN;
        
        float3 V = normalize(float3(position)); // float3(distance));   // <- using position = less color flickering as you navigate
        float3 R = normalize(reflect(-L, normal));
        float dotRV = dot(R, V);
        if(dotRV >= 0) color += control.lighting.specular * pow(dotRV, 2);
    }
    
    return color;
}

//MARK: -

#define NULL 0

float rayMarch // distance, or 0
(
 float3 rayDir,
 constant Control &control,
 device BoundsData *boundsData)
{
    float de,distance = 0.0;
    float3 position;

    for(int i = 0; i < control.maxSteps; ++i) {
        position = control.camera + rayDir * distance;
        
        de = DE(position, control);
        if(de < control.epsilon) {
            
            if(boundsData != NULL) {
                boundsData->position += position;
                ++(boundsData->count);
            }
            
            return distance;
        }
        
        distance += de * control.deScale;
        if(distance > control.fog) return 0;
    }

    return 0;
}

//MARK: -

kernel void mandelBoxShader
(
 texture2d<float, access::write> outTexture [[texture(0)]],
 texture2d<float, access::read> coloringTexture [[texture(1)]],
 constant Control &control [[buffer(0)]],
 device BoundsData *boundsData [[buffer(1)]],   // average position of object hits
 uint2 p [[thread_position_in_grid]])
{
    if(p.x > uint(control.xSize) || p.y > uint(control.ySize)) return;
    
    float den = float(control.xSize);
    float dx =  control.zoom * (float(p.x)/den - 0.5);
    float dy = -control.zoom * (float(p.y)/den - 0.5);
    
    float3 direction = normalize((control.sideVector * dx) + (control.topVector * dy) + control.viewVector);
    
    // occasionally add ray hit position to objects' position accumulator dataset
    device BoundsData *b = boundsData;
    if(((p.x & 15) != 0) || (p.y & 15) != 0) b = NULL;
    
    float3 color = float3();

    float distance = rayMarch(direction,control,b);
    if(distance > 0) {
        float3 position = control.camera + distance * direction;
        float3 normal = getNormal(position,control);
        
        // use texture
        if(control.txtOnOff > 0) {
            float scale = control.txtCenter.z * 4;
            float len = length(position) / distance;
            float x = normal.x * len;
            float y = normal.z * len;
            float w = control.txtSize.x;
            float h = control.txtSize.y;
            float xx = w + (control.txtCenter.x * 4 + x * scale) * (w + len);
            float yy = h + (control.txtCenter.y * 4 + y * scale) * (h + len);
        
            uint2 pt;
            pt.x = uint(fmod(xx,w));
            pt.y = uint(control.txtSize.y - fmod(yy,h)); // flip Y coord
            color = coloringTexture.read(pt).xyz;
        }
        
        color += lighting(position,distance,normal,control);
   }
    
    outTexture.write(float4(color,1),p);
}

