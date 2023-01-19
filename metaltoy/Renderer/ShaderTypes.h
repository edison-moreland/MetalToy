//
//  ShaderTypes.h
//  metaltoy
//
//  Created by Edison Moreland on 1/5/23.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef struct
{
    vector_float2 position;
} Vertex;

typedef struct
{
    vector_float2 viewport;
    float time;
    float scale;
} FragmentParameters;

#endif /* ShaderTypes_h */
