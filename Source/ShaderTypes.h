#pragma once

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef struct {
    matrix_float4x4 transformMatrix;
    matrix_float3x3 endPosition;
} ArcBallData;

typedef struct {
    vector_float3 position;
    float diffuse;
    float specular;
    float saturation;
    float gamma;
} Lighting;

typedef struct {
    vector_float3 position;
    float count;
} BoundsData;

typedef struct {
    int version;
    vector_float3 camera;
    vector_float3 focus;
    int xSize,ySize;
    float zoom;
    ArcBallData aData;
    vector_float3 color;
    Lighting lighting;
    vector_float3 viewVector,topVector,sideVector;
    float deFactor1,deFactor2;
    float parallax;
    float fog;

    int Final_Iterations;
    int Box_Iterations;
    int maxSteps;
    
    float epsilon;
    float normalEpsilon;

    float fFinal_Iterations;
    float fBox_Iterations;
    float fMaxSteps;
    bool showBalls;
    bool doInversion;
    bool fourGen;

    float Clamp_y;
    float Clamp_DF;
    float box_size_z;
    float box_size_x;
    
    float KleinR;
    float KleinI;
    vector_float3 InvCenter;
    vector_float3 ReCenter;
    
    float DeltaAngle;
    float InvRadius;
    float deScale;
    
    int txtOnOff;
    vector_float2 txtSize;
    vector_float3 txtCenter;

}  Control;
