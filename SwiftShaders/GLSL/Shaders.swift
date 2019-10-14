import Foundation

//
// API
//
//iOS
//
// https://developer.apple.com/documentation/scenekit/scnshadable
//
// Unity
//
// https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html?_ga=2.58238190.574435706.1570166606-1567286478.1570166606
//

/*!
 @property shaderModifiers
 @abstract Dictionary of shader modifiers snippets, targeting entry points. The valid keys are the entry points described in the "Shader Modifier Entry Point" constants. The values are the code snippets formatted as described below.
 @discussion Shader modifiers allow you to inject shader code in the standard shaders of SceneKit. This injection is allowed in few controlled entry points, allowing specific kind of tasks in specific context. Each modifier can operate on specific structures along with access to global uniforms, that could be the standard SceneKit uniforms or its own declared uniforms.
 
 Shader modifiers can be used to tweak SceneKit rendering by adding custom code at the following entry points:
 1. vertex   (SCNShaderModifierEntryPointGeometry)
 2. surface  (SCNShaderModifierEntryPointSurface)
 3. lighting (SCNShaderModifierEntryPointLightingModel)
 4. fragment (SCNShaderModifierEntryPointFragment)
 See below for a detailed explanation of these entry points and the context they provide.
 
 Shader modifiers can be written in either GLSL or the Metal Shading Language. Metal shaders won't run on iOS 8 and macOS 10.10 or earlier.
 
 The structure of a shader modifier is:
 
 GLSL
 | uniform float myGrayAmount = 3.0; // Custom GLSL uniforms declarations are of the form `[uniform type uniformName [= defaultValue]]`
 |
 | // Optional global function definitions (for Metal: references to uniforms in global functions are not supported).
 | float mySin(float t) {
 |    return sin(t);
 | }
 |
 | [#pragma transparent | opaque]
 | [#pragma body]
 |
 | // the shader modifier code snippet itself
 | vec3 myColor = myGrayAmount;
 | _output.color.rgb += myColor;
 
 Metal Shading Language
 | #pragma arguments
 | float myGrayAmount; // Custom Metal uniforms declarations require a #pragma and are of the form `[type name]`
 |
 | // Optional global function definitions (for Metal: references to uniforms in global functions are not supported).
 | float mySin(float t) {
 |    return sin(t);
 | }
 |
 | [#pragma transparent | opaque]
 | [#pragma body]
 |
 | // the shader modifier code snippet itself
 | float3 myColor = myGrayAmount;
 | _output.color.rgb += myColor;
 
 The `#pragma body` directive
 Is only needed if you declared functions that must not be included in the shader code itself.
 
 The `#pragma transparent` directive
 Forces the rendering to be blended using the following equation:
 _output.color.rgb + (1 - _output.color.a) * dst.rgb;
 where `dst` represents the current fragment color. The rgb components must be premultiplied.
 
 The `#pragma opaque` directive
 Forces the rendering to be opaque. It then ignores the alpha component of the fragment.
 
 When using Metal, you can also transfer varying values from the vertex shader (geometry shader modifier) to the fragment shader (surface and/or fragment shader modifier):
 1. Start by declaring the varying values in at least one of the shader modifiers:
 
 Metal Shading Language
 | #pragma varyings
 | half3 myVec;
 
 2. Then write the varying values from the vertex shader (geometry shader modifier):
 
 Metal Shading Language
 | #pragma body
 | out.myVec = _geometry.normal.xyz * 0.5h + 0.5h;
 
 3. Finally read the varying values from the fragment shader (surface and/or fragment shader modifier):
 
 Metal Shading Language
 | _output.color.rgb = saturate(in.myVec);
 
 SceneKit declares the following built-in uniforms:
 
 GLSL                                        | Metal Shading Language                                |
 --------------------------------------------┼-------------------------------------------------------┤
 float u_time                                | float    scn_frame.time                               | The current time, in seconds
 vec2  u_inverseResolution                   | float2   scn_frame.inverseResolution                  | 1.0 / screen size
 --------------------------------------------┼-------------------------------------------------------┤
 mat4  u_viewTransform                       | float4x4 scn_frame.viewTransform                      | See SCNViewTransform
 mat4  u_inverseViewTransform                | float4x4 scn_frame.inverseViewTransform               |
 mat4  u_projectionTransform                 | float4x4 scn_frame.projectionTransform                | See SCNProjectionTransform
 mat4  u_inverseProjectionTransform          | float4x4 scn_frame.inverseProjectionTransform         |
 --------------------------------------------┼-------------------------------------------------------┤
 mat4  u_normalTransform                     | float4x4 scn_node.normalTransform                     | See SCNNormalTransform
 mat4  u_modelTransform                      | float4x4 scn_node.modelTransform                      | See SCNModelTransform
 mat4  u_inverseModelTransform               | float4x4 scn_node.inverseModelTransform               |
 mat4  u_modelViewTransform                  | float4x4 scn_node.modelViewTransform                  | See SCNModelViewTransform
 mat4  u_inverseModelViewTransform           | float4x4 scn_node.inverseModelViewTransform           |
 mat4  u_modelViewProjectionTransform        | float4x4 scn_node.modelViewProjectionTransform        | See SCNModelViewProjectionTransform
 mat4  u_inverseModelViewProjectionTransform | float4x4 scn_node.inverseModelViewProjectionTransform |
 --------------------------------------------┼-------------------------------------------------------┤
 mat2x3 u_boundingBox;                       | float2x3 scn_node.boundingBox                         | The bounding box of the current geometry, in model space, u_boundingBox[0].xyz and u_boundingBox[1].xyz being respectively the minimum and maximum corner of the box.
 mat2x3 u_worldBoundingBox;                  | float2x3 scn_node.worldBoundingBox                    | The bounding box of the current geometry, in world space.
 
 When writing shaders using the Metal Shading Language a complete description of the type of the scn_frame variable (SCNSceneBuffer) can be found in the <SceneKit/scn_metal> header file.
 The type of the scn_node variable is generated at compile time and there's no corresponding header file in the framework.
 
 In addition to these built-in uniforms, it is possible to use custom uniforms:
 
 The SCNGeometry and SCNMaterial classes are key-value coding compliant classes, which means that you can set values for arbitrary keys. Even if the key `myAmplitude` is not a declared property of the class, you can still set a value for it.
 Declaring a `myAmplitude` uniform in the shader modifier makes SceneKit observe the reveiver's `myAmplitude` key. Any change to that key will make SceneKit bind the uniform with the new value.
 
 The following GLSL and Metal Shading Language types (and their Objective-C counterparts) can be used to declare (and bind) custom uniforms:
 
 GLSL        | Metal Shading Language | Objective-C                           |
 ------------┼------------------------┼---------------------------------------┤
 int         | int                    | NSNumber, NSInteger, int              |
 float       | float                  | NSNumber, CGFloat, float, double      |
 vec2        | float2                 | CGPoint                               |
 vec3        | float3                 | SCNVector3                            |
 vec4        | float4                 | SCNVector4                            |
 mat4, mat44 | float4x4               | SCNMatrix4                            |
 sampler2D   | texture2d              | SCNMaterialProperty                   |
 samplerCube | texturecube            | SCNMaterialProperty (with a cube map) |
 -           | device const T*        | MTLBuffer                             | Feature introduced in macOS 10.13, iOS 11.0 and tvOS 11.0
 -           | struct {...}           | NSData                                | The entire struct can be set using NSData but it is also possible to set individual members using the member's name as a key and a value compatible with the member's type
 
 Common scalar types wrapped into a NSValue are also supported.
 
 The following prefixes are reserved by SceneKit and should not be used in custom names:
 1. u_
 2. a_
 3. v_
 
 Custom uniforms can be animated using explicit animations.
 */

/*!
 @constant SCNShaderModifierEntryPointSurface
 @abstract This is the entry point to alter the surface representation of the material, before the lighting has taken place.
 
 Structures available from the SCNShaderModifierEntryPointSurface entry point:
 
 | struct SCNShaderSurface {
 |    float3 view;                     // Direction from the point on the surface toward the camera (V)
 |    float3 position;                 // Position of the fragment
 |    float3 normal;                   // Normal of the fragment (N)
 |    float3 geometryNormal;           // Geometric normal of the fragment (normal map is ignored)
 |    float3 tangent;                  // Tangent of the fragment
 |    float3 bitangent;                // Bitangent of the fragment
 |    float4 ambient;                  // Ambient property of the fragment
 |    float2 ambientTexcoord;          // Ambient texture coordinates
 |    float4 diffuse;                  // Diffuse property of the fragment. Alpha contains the opacity.
 |    float2 diffuseTexcoord;          // Diffuse texture coordinates
 |    float4 specular;                 // Specular property of the fragment
 |    float2 specularTexcoord;         // Specular texture coordinates
 |    float4 emission;                 // Emission property of the fragment
 |    float2 emissionTexcoord;         // Emission texture coordinates
 |    float4 multiply;                 // Multiply property of the fragment
 |    float2 multiplyTexcoord;         // Multiply texture coordinates
 |    float4 transparent;              // Transparent property of the fragment
 |    float2 transparentTexcoord;      // Transparent texture coordinates
 |    float4 reflective;               // Reflective property of the fragment
 |    float  metalness;                // Metalness property of the fragment
 |    float2 metalnessTexcoord;        // Metalness texture coordinates
 |    float  roughness;                // Roughness property of the fragment
 |    float2 roughnessTexcoord;        // Roughness texture coordinates
 |    float4 selfIllumination;         // Self Illumination property of the fragment. Available since macOS 10.13, iOS 11, tvOS 11 and watchOS 4. Available as `emission` in previous versions.
 |    float2 selfIlluminationTexcoord; // Self Illumination texture coordinates. Available since macOS 10.13, iOS 11, tvOS 11 and watchOS 4. Available as `emissionTexcoord` in previous versions.
 |    float  ambientOcclusion;         // Ambient Occlusion property of the fragment. Available macOS 10.13, iOS 11, tvOS 11 and watchOS 4. Available as `multiply` in previous versions.
 |    float2 ambientOcclusionTexcoord; // Ambient Occlusion texture coordinates. Available since macOS 10.13, iOS 11, tvOS 11 and watchOS 4. Available as `multiplyTexcoord` in previous versions.
 |    float  shininess;                // Shininess property of the fragment
 |    float  fresnel;                  // Fresnel property of the fragment
 | } _surface;
 |
 | Access: ReadWrite
 | Stages: Fragment shader only
 
 All geometric fields are in view space.
 All the other properties will be colors (texture have already been sampled at this stage) or floats. You can however do an extra sampling of standard textures if you want.
 In this case the naming pattern is u_<property>Texture. For example u_diffuseTexture or u_reflectiveTexture. Note that you have to be sure that the material do have a texture
 set for this property, otherwise you'll trigger a shader compilation error.
 
 Example: Procedural black and white stripes
 
 GLSL
 | uniform float Scale = 12.0;
 | uniform float Width = 0.25;
 | uniform float Blend = 0.3;
 |
 | vec2 position = fract(_surface.diffuseTexcoord * Scale);
 | float f1 = clamp(position.y / Blend, 0.0, 1.0);
 | float f2 = clamp((position.y - Width) / Blend, 0.0, 1.0);
 | f1 = f1 * (1.0 - f2);
 | f1 = f1 * f1 * 2.0 * (3. * 2. * f1);
 | _surface.diffuse = mix(vec4(1.0), vec4(0.0), f1);
 
 Metal Shading Language
 | #pragma arguments
 | float Scale;
 | float Width;
 | float Blend;
 |
 | float2 position = fract(_surface.diffuseTexcoord * Scale);
 | float f1 = clamp(position.y / Blend, 0.0, 1.0);
 | float f2 = clamp((position.y - Width) / Blend, 0.0, 1.0);
 | f1 = f1 * (1.0 - f2);
 | f1 = f1 * f1 * 2.0 * (3. * 2. * f1);
 | _surface.diffuse = mix(float4(1.0), float4(0.0), f1);
 
 */

// MARK: - Surface

let simpleHalfColoringSurfaceShader = """
vec4 orig = _surface.diffuse;
vec4 transformed_position = u_inverseModelTransform * u_inverseViewTransform * vec4(_surface.position, 1.0);
if (transformed_position.x < 0.0) {
_surface.diffuse = mix(vec4(1.0,0.0,0.0,1.0), orig, 0.5);
}
"""

let simpleHalfColoringFromScreenSizeSurfaceShader = """
if (_surface.position.x < 0.0) {
_surface.diffuse = vec4(0.0, 0.0, 1.0, 1.0);
} else {
_surface.diffuse = vec4(1.0, 0.8, 0.2, 1.0);
}
"""

let gradientColoringFromScreenSizeSurfaceShader = """
_surface.diffuse = vec4(0.0, 0.0, gl_FragCoord.xy.x * u_inverseResolution.x, 1.0);
"""

let coloringSurfaceShader = "float flakeSize = sin(u_time * 0.2);\n"
    + "float flakeIntensity = 0.7;\n"
    + "vec3 paintColor0 = vec3(1, 1, 1);\n"
    + "vec3 paintColor1 = vec3(0, 1, 1);\n"
    + "vec3 flakeColor = vec3(flakeIntensity, flakeIntensity, flakeIntensity);\n"
    + "vec3 rnd =  texture2D(u_diffuseTexture, _surface.diffuseTexcoord * vec2(1.0) * sin(u_time*0.1) ).rgb;\n"
    + "vec3 nrm1 = normalize(0.05 * rnd + 0.95 * _surface.normal);\n"
    + "vec3 nrm2 = normalize(0.3 * rnd + 0.4 * _surface.normal);\n"
    + "float fresnel1 = clamp(dot(nrm1, _surface.view), 0.0, 1.0);\n"
    + "float fresnel2 = clamp(dot(nrm2, _surface.view), 0.0, 1.0);\n"
    + "vec3 col = mix(paintColor0, paintColor1, fresnel1);\n"
    + "col += pow(fresnel2, 106.0) * flakeColor;\n"
    + "_surface.normal = nrm1;\n"
    + "_surface.diffuse = vec4(col.r,col.b,col.g, 1.0);\n"
    + "_surface.emission = (_surface.reflective * _surface.reflective) * 2.0;\n"
    + "_surface.reflective = vec4(0.0);\n"

let tooningShader = """
vec3 lDir = normalize(vec3(0.1,1.0,1.0));
float dotProduct = dot(_surface.normal,lDir);

_lightingContribution.diffuse += (dotProduct * dotProduct * _light.intensity.rgb);
_lightingContribution.diffuse = floor(_lightingContribution.diffuse * 4.0) / 3.0;

vec3 halfVector = normalize(lDir + _surface.view);

dotProduct = max(0.0, pow(max(0.0, dot(_surface.normal, halfVector)), _surface.shininess));
dotProduct = floor(dotProduct * 3.0) / 3.0;

//_lightingContribution.specular += (dotProduct * _light.intensity.rgb);
_lightingContribution.specular = vec3(0,0,0);
"""

let outliningShader = """
#pragma body

const float PIover2 = (3.14159265358979 / 2.0);
const float lineTolerance = 1.0;

float dotProduct = dot(_surface.view, _surface.normal);

if ( (PIover2 + lineTolerance) > dotProduct && dotProduct > (PIover2 - lineTolerance) ) {
  _output.color.rgba = vec4(0.0, 0.0, 0.0, 1.0);
}
"""

// MARK: - Geometry

let twistingGeometryShader = """
// a function that creates a rotation transform matrix around X
mat4 rotationAroundX(float angle)
{
    return mat4(1.0,    0.0,         0.0,        0.0,
                0.0,    cos(angle), -sin(angle), 0.0,
                0.0,    sin(angle),  cos(angle), 0.0,
                0.0,    0.0,         0.0,        1.0);
}

#pragma body

float rotationAngle = _geometry.position.x * sin(u_time);
mat4 rotationMatrix = rotationAroundX(rotationAngle);

// position is a vec4
_geometry.position *= rotationMatrix;

// normal is a vec3
vec4 twistedNormal = vec4(_geometry.normal, 1.0) * rotationMatrix;
_geometry.normal   = twistedNormal.xyz;
"""

// MARK: - Fragment

let appearingFragmentShader =
"""
#pragma arguments

float revealage;
texture2d<float, access::sample> noiseTexture;

#pragma transparent
#pragma body

const float edgeWidth = 0.02;
const float edgeBrightness = 2;
const float3 innerColor = float3(0.4, 0.8, 1);
const float3 outerColor = float3(0, 0.5, 1);
const float noiseScale = 3;

constexpr sampler noiseSampler(filter::linear, address::repeat);
float2 noiseCoords = noiseScale * _surface.ambientTexcoord;
float noiseValue = noiseTexture.sample(noiseSampler, noiseCoords).r;

if (noiseValue > revealage) {
discard_fragment();
}

float edgeDist = revealage - noiseValue;
if (edgeDist < edgeWidth) {
float t = edgeDist / edgeWidth;
float3 edgeColor = edgeBrightness * mix(outerColor, innerColor, t);
_output.color.rgb = edgeColor;
}
"""
