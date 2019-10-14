#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

using namespace metal;

struct NodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewProjectionTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float2x3 boundingBox;
};

struct VertexInput {
    float3 position  [[attribute(SCNVertexSemanticPosition)]];
    float2 texCoords [[ attribute(SCNVertexSemanticTexcoord0) ]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

struct FragmentUniforms {
    float brightness;
};

vertex VertexOut textureBrightnessSamplerVertex(VertexInput in [[ stage_in ]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.uv = in.texCoords;
    return out;
}

fragment float4 textureBrightnessSamplerFragment(VertexOut out [[ stage_in ]], texture2d<float, access::sample> customTexture [[texture(0)]], constant FragmentUniforms &uniforms [[buffer(0)]]) {
    constexpr sampler softNoiseSampler(coord::normalized, filter::linear, address::repeat);
    return customTexture.sample(softNoiseSampler, out.uv).rgba * uniforms.brightness;
}
