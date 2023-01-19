//
//  MetalToyUserDylib.metal
//  metaltoy
//
//  Created by Edison Moreland on 1/10/23.
//

#include "MetalToyUserDylib.h"
#include <metal_stdlib>

using namespace metal;

float4 MetalToy::frag(float2 coord, float2 viewport, float time)
{
    float2 orbit = viewport/2 + (float2(sin(time), cos(time))*100);
    
    float distance = length(coord - orbit) - 10;
    if (distance > 0) {
        return float4(0.0, 0.0, 0.0, 0.0);
    } else {
        return float4(1.0, 1.0, 1.0, 0.0);
    }
}
