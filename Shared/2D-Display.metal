//
//  Conway.metal
//  LifeLab
//
//  Created by Jonathan Attfield on 08/01/2021.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float2 uv;
};

vertex Vertex vertexShader(constant float4* vertices [[buffer(0)]],
                           uint id [[vertex_id]]) {
    return {
        .position = vertices[id],
        .uv = (vertices[id].xy + float2(1)) / float2(2)
    };
}

fragment float4 fragmentShader(Vertex vtx [[stage_in]],
                               texture2d<uint> generation [[texture(0)]]) {
    constexpr sampler smplr(coord::normalized,
                            address::clamp_to_zero,
                            filter::nearest);
    uint cell = generation.sample(smplr, vtx.uv).r;
    return float4(cell);
}




