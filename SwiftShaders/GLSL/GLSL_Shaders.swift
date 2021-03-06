import Foundation

// iOS GLSL Shaders

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

let coloringFragmentShader = """
// Normalized pixel coordinates (from 0 to 1)
vec2 uv = gl_FragCoord.xy * u_inverseResolution.xy;

// Time varying pixel color
vec3 col = 0.5 + 0.5*cos(u_time+uv.xyx+vec3(0,2,4));

// Output to screen
_output.color.rgba = vec4(col,1);
"""

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

let discoveringFragment = """
// Normalized pixel coordinates (from 0 to 1)
vec2 uv = gl_FragCoord.xy * u_inverseResolution.xy;

// Time varying pixel color
vec3 col = texture2D(u_diffuseTexture, uv).rgb;

// Output to screen
_output.color.rgba = vec4(col,1);
"""

let gaussianFragment = """
vec2 uv = _surface.diffuseTexcoord.xy;

float xValue = u_inverseResolution.x * 3.0;
float yValue = u_inverseResolution.y * 2.0;

float blur = 5.2;

// Apply Gaussian Blur
vec3 col = texture2D(u_diffuseTexture, vec2(uv.x - 4.0 * xValue * blur, uv.y - 4.0 * yValue * blur)).rgb * 0.01621621621;
col += texture2D(u_diffuseTexture, vec2(uv.x - 3.0 * xValue * blur, uv.y - 3.0 * yValue * blur)).rgb * 0.0540540541;
col += texture2D(u_diffuseTexture, vec2(uv.x - 2.0 * xValue * blur, uv.y - 2.0 * yValue * blur)).rgb * 0.1216216216;
col += texture2D(u_diffuseTexture, vec2(uv.x - 1.0 * xValue * blur, uv.y - 1.0 * yValue * blur)).rgb * 0.1945945946;
col += texture2D(u_diffuseTexture, vec2(uv.x, uv.y)).rgb * 0.2270270270;
col += texture2D(u_diffuseTexture, vec2(uv.x + 1.0 * xValue * blur, uv.y + 1.0 * yValue * blur)).rgb * 0.1945945946;
col += texture2D(u_diffuseTexture, vec2(uv.x + 2.0 * xValue * blur, uv.y + 2.0 * yValue * blur)).rgb * 0.1216216216;
col += texture2D(u_diffuseTexture, vec2(uv.x + 3.0 * xValue * blur, uv.y + 3.0 * yValue * blur)).rgb * 0.0540540541;
col += texture2D(u_diffuseTexture, vec2(uv.x + 4.0 * xValue * blur, uv.y + 4.0 * yValue * blur)).rgb * 0.01621621621;

// Output to screen
_output.color.rgba = vec4(col,1);
"""

let wavingFragment = """
vec2 uv = _surface.diffuseTexcoord.xy;
float speed = 4.0;
float turbulence = 10.0;
float dist = length(uv);
vec2 center = vec2(0.5, 0.5);
uv += uv / dist * cos(dist * turbulence - u_time * speed) * 0.008;
uv = uv * 0.5;
vec3 col = texture2D(u_diffuseTexture, uv).rgb;
_output.color.rgba = vec4(col,1);
"""

let dropEffectFragment = """
vec2 center = vec2(0.5,0.5);
float speed = 0.035;
vec2 uv = _surface.diffuseTexcoord.xy;
vec3 col = vec4(uv,0.5+0.5*sin(u_time),1.0).xyz;
vec3 texcol;
float invAr = u_inverseResolution.x / u_inverseResolution.y;
float x = (center.x-uv.x);
float y = (center.y-uv.y) * invAr;
float r = -(x*x + y*y);
float z = 1.0 + 0.5*sin((r+u_time*speed)/0.013);
texcol.x = z;
texcol.y = z;
texcol.z = z;
_output.color.rgba = vec4(col*texcol, 1.0);
"""
