
#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 1, binding = 0) uniform ModelBufferObject {
    mat4 model;
};

// Input attributes from Blade struct
layout(location = 0) in vec4 v0;  // Position and direction
layout(location = 1) in vec4 v1;  // Bezier point and height
layout(location = 2) in vec4 v2;  // Physical model guide and width
layout(location = 3) in vec4 up;  // Up vector and stiffness coefficient

// Output to tessellation control shader
layout(location = 0) out vec4 v0_out;
layout(location = 1) out vec4 v1_out;
layout(location = 2) out vec4 v2_out;
layout(location = 3) out vec4 up_out;

out gl_PerVertex {
    vec4 gl_Position;
};

void main() {
	 // Pass through all Blade data to tessellation control shader
    v0_out = v0;
    v1_out = v1;
    v2_out = v2;
    up_out = up;
    
    // Set position for tessellation (use v0 which contains the blade base position)
    gl_Position = model * vec4(v0.xyz, 1.0);
}
