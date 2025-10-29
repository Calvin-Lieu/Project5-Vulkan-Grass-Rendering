#version 450
#extension GL_ARB_separate_shader_objects : enable

// set = 1 : per-model transform (for blades bound to a model instance)
layout(set = 1, binding = 0) uniform ModelUBO {
    mat4 model;
} modelUBO;

// Vertex attributes for a single patch (one blade)
// Matches Blade::getAttributeDescriptions(): 4x vec4
layout(location = 0) in vec4 in_p0; // xyz = v0, w = orientation
layout(location = 1) in vec4 in_p1; // xyz = v1, w = height
layout(location = 2) in vec4 in_p2; // xyz = v2, w = width
layout(location = 3) in vec4 in_up; // xyz = up, w = stiffness

// Pass to tessellation (world space control points and packed scalars)
layout(location = 0) out vec4 out_p0;
layout(location = 1) out vec4 out_p1;
layout(location = 2) out vec4 out_p2;
layout(location = 3) out vec4 out_up;

out gl_PerVertex {
    vec4 gl_Position;
};

void main()
{
    // Transform control points and up-vector to world space
    vec4 wp0 = modelUBO.model * vec4(in_p0.xyz, 1.0);
    vec4 wp1 = modelUBO.model * vec4(in_p1.xyz, 1.0);
    vec4 wp2 = modelUBO.model * vec4(in_p2.xyz, 1.0);
    vec3 wup = normalize((modelUBO.model * vec4(in_up.xyz, 0.0)).xyz);

    // Preserve packed scalars in .w
    out_p0 = vec4(wp0.xyz, in_p0.w); // orientation
    out_p1 = vec4(wp1.xyz, in_p1.w); // height
    out_p2 = vec4(wp2.xyz, in_p2.w); // width
    out_up = vec4(wup, in_up.w);     // stiffness

    // Patch origin position (used by TCS via gl_in)
    gl_Position = wp0;
}
