#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(vertices = 1) out;

// set = 0 : camera
layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

in gl_PerVertex {
    vec4 gl_Position;
} gl_in[];

out gl_PerVertex {
    vec4 gl_Position;
} gl_out[];

// Pass-through of control points to TES
layout(location = 0) in  vec4 in_p0[];
layout(location = 1) in  vec4 in_p1[];
layout(location = 2) in  vec4 in_p2[];
layout(location = 3) in  vec4 in_up[];

layout(location = 0) out vec4 t_p0[];
layout(location = 1) out vec4 t_p1[];
layout(location = 2) out vec4 t_p2[];
layout(location = 3) out vec4 t_up[];

void main()
{
    // Pass-through
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

    t_p0[gl_InvocationID] = in_p0[gl_InvocationID];
    t_p1[gl_InvocationID] = in_p1[gl_InvocationID];
    t_p2[gl_InvocationID] = in_p2[gl_InvocationID];
    t_up[gl_InvocationID] = in_up[gl_InvocationID];

    // Distance-based tess level (smooth, bounded)
    vec3 camPos = inverse(camera.view)[3].xyz;
    vec3 root   = in_p0[gl_InvocationID].xyz;
    vec3 upN    = normalize(in_up[gl_InvocationID].xyz);
    vec3 viewVec= root - camPos - upN * dot(root - camPos, upN);
    float dist  = max(length(viewVec), 1e-3);

    const float nearRef = 6.0;
    const float minTess = 2.0;
    const float maxTess = 8.0;

    float level = clamp(nearRef / dist, 0.0, 1.0);
    float tess  = mix(minTess, maxTess, level);

    // Set tess levels once per patch (invocation 0)
    if (gl_InvocationID == 0) {
        gl_TessLevelInner[0] = tess;
        gl_TessLevelInner[1] = tess;
        gl_TessLevelOuter[0] = tess;
        gl_TessLevelOuter[1] = tess;
        gl_TessLevelOuter[2] = tess;
        gl_TessLevelOuter[3] = tess;
    }
}
