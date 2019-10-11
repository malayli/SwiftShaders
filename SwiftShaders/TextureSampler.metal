#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

using namespace metal;

//struct SCNSceneBuffer {
//    float4x4    viewTransform;
//    float4x4    inverseViewTransform; // view space to world space
//    float4x4    projectionTransform;
//    float4x4    viewProjectionTransform;
//    float4x4    viewToCubeTransform; // view space to cube texture space (right-handed, y-axis-up)
//    float4      ambientLightingColor;
//    float4      fogColor;
//    float3      fogParameters; // x: -1/(end-start) y: 1-start*x z: exponent
//    float       time;     // system time elapsed since first render with this shader
//    float       sinTime;  // precalculated sin(time)
//    float       cosTime;  // precalculated cos(time)
//    float       random01; // random value between 0.0 and 1.0
//};

//enum {
//SCNVertexSemanticPosition,
//SCNVertexSemanticNormal,
//SCNVertexSemanticTangent,
//SCNVertexSemanticColor,
//SCNVertexSemanticBoneIndices,
//SCNVertexSemanticBoneWeights,
//SCNVertexSemanticTexcoord0,
//SCNVertexSemanticTexcoord1,
//SCNVertexSemanticTexcoord2,
//SCNVertexSemanticTexcoord3
//};

// In custom shaders or in shader modifiers, you also have access to node relative information.
// This is done using an argument named "scn_node", which must be a struct with only the necessary fields
// among the following list:
//
// float4x4 modelTransform;
// float4x4 inverseModelTransform;
// float4x4 modelViewTransform;
// float4x4 inverseModelViewTransform;
// float4x4 normalTransform; // This is the inverseTransposeModelViewTransform, need for normal transformation
// float4x4 modelViewProjectionTransform;
// float4x4 inverseModelViewProjectionTransform;
// float2x3 boundingBox;
// float2x3 worldBoundingBox;

struct MyNodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewProjectionTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float2x3 boundingBox;
};

struct VertexInput {
    float3 position  [[attribute(0)]];
    float3 normal    [[attribute(1)]];
    float2 tangent [[attribute(2)]];
    float4 color [[attribute(3)]];
};

struct VertexOut
{
    float4 position [[position]];
    float3 normal;
    float2 uv;
    float4 color;
};

vertex VertexOut vertex_main(VertexInput in [[ stage_in ]], constant MyNodeBuffer& scn_node [[buffer(1)]])
{
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.normal = in.normal;
    return out;
}

fragment float4 fragment_main(VertexOut out [[ stage_in ]])
{
    return out.color;
}
