#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(vertices = 1) out;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// Input from vertex shader
layout(location = 0) in vec4 v0_in[];
layout(location = 1) in vec4 v1_in[];
layout(location = 2) in vec4 v2_in[];
layout(location = 3) in vec4 up_in[];

// Output to tessellation evaluation shader
layout(location = 0) out vec4 v0_out[];
layout(location = 1) out vec4 v1_out[];
layout(location = 2) out vec4 v2_out[];
layout(location = 3) out vec4 up_out[];

void main() {
    // Don't move the origin location of the patch
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

    // Pass through all Blade data to tessellation evaluation shader
    v0_out[gl_InvocationID] = v0_in[gl_InvocationID];
    v1_out[gl_InvocationID] = v1_in[gl_InvocationID];
    v2_out[gl_InvocationID] = v2_in[gl_InvocationID];
    up_out[gl_InvocationID] = up_in[gl_InvocationID];

    // Set tessellation levels (only done by first invocation)
    if (gl_InvocationID == 0) {
        // Calculate distance to camera for LOD
        vec3 worldPos = v0_in[0].xyz;
        vec3 cameraPos = inverse(camera.view)[3].xyz;
        float distance = length(cameraPos - worldPos);
        
        // Adaptive tessellation based on distance
        float maxDistance = 50.0;
        float tessLevel = mix(8.0, 2.0, clamp(distance / maxDistance, 0.0, 1.0));
        
        // Tessellation levels for quad patch
        // Outer levels: left, bottom, right, top
        gl_TessLevelOuter[0] = tessLevel;  // Left edge (along height)
        gl_TessLevelOuter[1] = 2.0;       // Bottom edge (along width) - minimal
        gl_TessLevelOuter[2] = tessLevel;  // Right edge (along height)
        gl_TessLevelOuter[3] = 2.0;       // Top edge (along width) - minimal
        
        // Inner levels: horizontal, vertical subdivision
        gl_TessLevelInner[0] = 2.0;       // Horizontal (width) - minimal
        gl_TessLevelInner[1] = tessLevel; // Vertical (height) - more detail for curvature
    }
}