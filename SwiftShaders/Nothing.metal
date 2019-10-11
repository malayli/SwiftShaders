#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct MyNodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
    float2x3 boundingBox;
};

struct VertexInput {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texCoords [[ attribute(SCNVertexSemanticTexcoord0) ]];
    float3 normal  [[ attribute(SCNVertexSemanticNormal) ]];
};

struct VertexOut
{
    float4 color;
    float4 position [[position]];
    float2 uv;
    float3 normal;
};

struct FragmentUniforms {
    float brightness;
};

vertex VertexOut nothingVertex(VertexInput in [[ stage_in ]],
                                     constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                                     constant MyNodeBuffer& scn_node [[buffer(1)]])
{
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.uv = in.texCoords;
    out.normal = in.normal;
    return out;
}

fragment float4 nothingFragment(VertexOut vertexOut [[stage_in]], constant FragmentUniforms &uniforms [[buffer(0)]])
{
    return float4(uniforms.brightness * vertexOut.color.rgb, vertexOut.color.a);
}
