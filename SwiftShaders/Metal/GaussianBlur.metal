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

vertex VertexOut gaussianBlurVertex(VertexInput in [[ stage_in ]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.uv = in.texCoords;
    return out;
}

fragment float4 gaussianBlurFragment(VertexOut fragmentIn [[ stage_in ]],
                                     texture2d<float, access::sample> customTexture [[texture(0)]]) {
    float2 offset = fragmentIn.uv;
    constexpr sampler qsampler(coord::normalized,address::clamp_to_edge);
//    float4 color = texture.sample(qsampler, coordinates);
    float width = customTexture.get_width();
    float height = customTexture.get_width();
    float xPixel = (1 / width) * 3;
    float yPixel = (1 / height) * 2;
    
    float3 sum = float3(0.0, 0.0, 0.0);
    
    // code from https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
    
    // 9 tap filter
    sum += customTexture.sample(qsampler, float2(offset.x - 4.0*xPixel, offset.y - 4.0*yPixel)).rgb * 0.0162162162;
    sum += customTexture.sample(qsampler, float2(offset.x - 3.0*xPixel, offset.y - 3.0*yPixel)).rgb * 0.0540540541;
    sum += customTexture.sample(qsampler, float2(offset.x - 2.0*xPixel, offset.y - 2.0*yPixel)).rgb * 0.1216216216;
    sum += customTexture.sample(qsampler, float2(offset.x - 1.0*xPixel, offset.y - 1.0*yPixel)).rgb * 0.1945945946;
    
    sum += customTexture.sample(qsampler, offset).rgb * 0.2270270270;
    
    sum += customTexture.sample(qsampler, float2(offset.x + 1.0*xPixel, offset.y + 1.0*yPixel)).rgb * 0.1945945946;
    sum += customTexture.sample(qsampler, float2(offset.x + 2.0*xPixel, offset.y + 2.0*yPixel)).rgb * 0.1216216216;
    sum += customTexture.sample(qsampler, float2(offset.x + 3.0*xPixel, offset.y + 3.0*yPixel)).rgb * 0.0540540541;
    sum += customTexture.sample(qsampler, float2(offset.x + 4.0*xPixel, offset.y + 4.0*yPixel)).rgb * 0.0162162162;
    
    float4 adjusted;
    adjusted.rgb = sum;
//    adjusted.g = color.g;
    adjusted.a = 1;
    return adjusted;
}
