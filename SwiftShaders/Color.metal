#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct NodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
    float2x3 boundingBox;
};

struct VertexInput {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texCoords [[ attribute(SCNVertexSemanticTexcoord0) ]];
};

struct VertexOut
{
    float4 position [[position]];
    float2 uv;
};

struct FragmentUniforms {
    float color;
};

vertex VertexOut colorVertex(VertexInput in [[ stage_in ]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.uv = in.texCoords;
    return out;
}

fragment float4 colorFragment(VertexOut vertexOut [[stage_in]], constant FragmentUniforms &uniforms [[buffer(0)]])
{
    return float4(uniforms.color, uniforms.color, uniforms.color, 1);
}
