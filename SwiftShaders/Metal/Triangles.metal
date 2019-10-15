#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct myPlaneNodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
    float2x3 boundingBox;
};

typedef struct {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texCoords [[attribute(SCNVertexSemanticTexcoord0)]];
} VertexInput;

static float rand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

static float2 uv2tri(float2 uv)
{
    float sx = uv.x - uv.y / 2;
    float sxf = fract(sx);
    float offs = step(fract(1 - uv.y), sxf);
    return float2(floor(sx) * 2 + sxf + offs, uv.y);
}

struct SimpleVertexWithUV
{
    float4 position [[position]];
    float2 uv;
};

vertex SimpleVertexWithUV trianglequiltVertex(VertexInput in [[ stage_in ]],
                                     constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                                     constant myPlaneNodeBuffer& scn_node [[buffer(1)]])
{
    SimpleVertexWithUV vert;
    vert.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    vert.uv = in.texCoords;
    return vert;
}

fragment float4 trianglequiltFragment(SimpleVertexWithUV in [[stage_in]],
                             constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                             constant myPlaneNodeBuffer& scn_node [[buffer(1)]])
{
    float4 fragColor;
    float2 uv = in.uv*10;
    float timer = scn_frame.time;
    uv.y += timer;

    float t = timer * 0.8;
    float tc = floor(t);
    float tp = smoothstep(0, 0.8, fract(t));

    float2 r1 = float2(floor(uv.y), tc);
    float2 r2 = float2(floor(uv.y), tc + 1);
    float offs = mix(rand(r1), rand(r2), tp);

    uv.x += offs * 8;

    float2 p = uv2tri(uv);
    float ph = rand(floor(p)) * 6.3 + p.y * 0.2;
    float c = abs(sin(ph + timer));

    fragColor = float4(c, c, c, 1);
    return(fragColor);
}
