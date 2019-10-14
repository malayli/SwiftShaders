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

vertex VertexOut textureSamplerVertex(VertexInput in [[ stage_in ]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.uv = in.texCoords;
    return out;
}

fragment float4 textureSamplerFragment(VertexOut out [[ stage_in ]], texture2d<float, access::sample> customTexture [[texture(0)]]) {
    constexpr sampler softNoiseSampler(coord::normalized, filter::linear, address::repeat);
    return customTexture.sample(softNoiseSampler, out.uv );
}
