#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(quads, equal_spacing, ccw) in;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

layout(set = 1, binding = 0) uniform ModelBufferObject {
    mat4 model;
} modelUBO;

// Input from tessellation control shader
layout(location = 0) in vec4 v0_in[];
layout(location = 1) in vec4 v1_in[];
layout(location = 2) in vec4 v2_in[];
layout(location = 3) in vec4 up_in[];

// Output to fragment shader
layout(location = 0) out vec3 fragPos;
layout(location = 1) out vec3 fragNormal;
layout(location = 2) out vec2 fragUV;

void main() {
    float u = gl_TessCoord.x;  // Width parameter (0 to 1)
    float v = gl_TessCoord.y;  // Height parameter (0 to 1)
    
    // Get blade data from first control point (since all are the same for this patch)
    vec3 v0 = v0_in[0].xyz;
    vec3 v1 = v1_in[0].xyz;
    vec3 v2 = v2_in[0].xyz;
    vec3 up = up_in[0].xyz;
    
    // Extract blade properties from w components
    float height = v1_in[0].w;
    float width = v2_in[0].w;
    float stiffness = up_in[0].w;
    
    // De Casteljau's algorithm to find point along Bezier curve
    vec3 a = v0 + v * (v1 - v0);      // Interpolate v0 to v1
    vec3 b = v1 + v * (v2 - v1);      // Interpolate v1 to v2
    vec3 c = a + v * (b - a);         // Final point on curve
    
    // Calculate tangent vectors
    vec3 t0 = normalize(b - a);       // Tangent along curve
    
    // Calculate bitangent (perpendicular to up and tangent)
    vec3 t1 = normalize(cross(up, t0));
    
    // Calculate normal
    vec3 normal = normalize(cross(t0, t1));
    
    // Create width offset based on u parameter
    // u = 0 -> left edge, u = 1 -> right edge, u = 0.5 -> center
    float widthOffset = (u - 0.5) * width;
    
    // Final world position
    vec3 worldPos = c + widthOffset * t1;
    
    // Transform to clip space - use the instance name
    gl_Position = camera.proj * camera.view * modelUBO.model * vec4(worldPos, 1.0);
    
    // Pass data to fragment shader
    fragPos = worldPos;
    fragNormal = normal;
    fragUV = vec2(u, v);  // UV coordinates for texturing
}