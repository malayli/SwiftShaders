#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>
  
constant float3 light_position = float3(50.0, 100.0, 50.0);
constant float4 light_color = float4(1.0, 1.0, 1.0, 1.0);
constant float4 materialAmbientColor = float4(0.3, 0.5, 0.9, 1.0);
constant float4 materialDiffuseColor = float4(0.4, 0.6, 1.0, 1.0);
constant float4 materialSpecularColor = float4(1.0, 1.0, 1.0, 1.0);
constant float  materialShine = 50.0;
  
typedef struct {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float3 normal  [[ attribute(SCNVertexSemanticNormal) ]];
    float4 color [[ attribute(SCNVertexSemanticColor) ]];
} MyVertexInput;
  
struct MyNodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
};
  
struct ColoredVertex
{
    float4 position [[position]];
    float3 normal;
    float4 color;
  
    float3 eye_direction_cameraspace;
    float3 light_direction_cameraspace;
};
  
vertex ColoredVertex myVertex(MyVertexInput in [[ stage_in ]],
                              constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                              constant MyNodeBuffer& scn_node [[buffer(1)]]
                              )
{
    float3 normal = in.normal;
  
  
    ColoredVertex vert;
    vert.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
  
    vert.color = in.color;
    vert.normal = (scn_node.normalTransform * float4(normal, 1.0)).xyz;
  
    float4 vertex_position_modelspace = float4(in.position, 1.0f );
      
    float3 vertex_position_cameraspace = ( scn_node.modelViewTransform * vertex_position_modelspace ).xyz;
    vert.eye_direction_cameraspace = float3(0.0f,0.0f,0.0f) - vertex_position_cameraspace;
  
    float3 light_position_cameraspace = ( scn_frame.viewTransform * float4(light_position,1.0f)).xyz;
    vert.light_direction_cameraspace = light_position_cameraspace + vert.eye_direction_cameraspace;
  
    return vert;
}
  
fragment half4 myFragment(ColoredVertex in [[stage_in]])
{
    half4 color;
  
    float4 ambient_color = materialAmbientColor;
  
    float3 n = normalize(in.normal);
    float3 l = normalize(in.light_direction_cameraspace);
    float n_dot_l = saturate( dot(n, l) );
  
    float4 diffuse_color = light_color * n_dot_l * materialDiffuseColor;
  
    float3 e = normalize(in.eye_direction_cameraspace);
    float3 r = -l + 2.0f * n_dot_l * n;
    float e_dot_r =  saturate( dot(e, r) );
    float4 specular_color = materialSpecularColor * light_color * pow(e_dot_r, materialShine);
  
    color = half4(ambient_color + diffuse_color + specular_color);
  
    return color;
}  
