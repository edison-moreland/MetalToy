//
//  MetalToyUserDylib.h
//  metaltoy
//
//  Created by Edison Moreland on 1/10/23.
//

#ifndef MetalToyUserDylib_h
#define MetalToyUserDylib_h

// By default, a dynamic library exports all symbols and this can cause namespace clashes.
// The sample selectively exports only the symbol that the app code looks for.
#define EXPORT __attribute__((visibility("default")))
namespace MetalToy
{
    EXPORT float4 frag(float2 coord, float2 viewport, float time);
}
#undef EXPORT

#endif /* MetalToyUserDylib_h */
