//
//  VertexShader.metal
//  metaltoy
//
//  Created by Edison Moreland on 1/10/23.
//

#include <simd/simd.h>
#include <metal_stdlib>
#include "ShaderTypes.h"
#include "MetalToyUserDylib.h"

using namespace metal;

struct RasterizerData
{
    float4 position [[position]];
};

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
         constant Vertex *vertices [[buffer(0)]])
{
    RasterizerData out;
    out.position = vector_float4(vertices[vertexID].position, 0.0, 1.0);

    return out;
}

fragment float4
fragmentShader(RasterizerData in [[stage_in]],
           constant FragmentParameters *param [[buffer(0)]])
{
    return MetalToy::frag(in.position.xy/param->scale, param->viewport/param->scale, param->time);
}
