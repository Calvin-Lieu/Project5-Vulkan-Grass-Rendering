#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(quads, equal_spacing, ccw) in;

// set = 0 : camera
layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// Inputs from TCS
layout(location = 0) in vec4 t_p0[];
layout(location = 1) in vec4 t_p1[];
layout(location = 2) in vec4 t_p2[];
layout(location = 3) in vec4 t_up[];

// Varyings to fragment
layout(location = 0) out vec3 v_normal;
layout(location = 1) out float v_param; // curve parameter along height

// Quadratic Bezier via De Casteljau
vec3 bezier3(vec3 a, vec3 b, vec3 c, float t)
{
    vec3 ab = mix(a, b, t);
    vec3 bc = mix(b, c, t);
    return mix(ab, bc, t);
}

void main()
{
    float u = gl_TessCoord.x; // across width
    float v = gl_TessCoord.y; // along height

    vec3 p0 = t_p0[0].xyz;
    vec3 p1 = t_p1[0].xyz;
    vec3 p2 = t_p2[0].xyz;

    float theta = t_p0[0].w; // orientation
    float height = t_p1[0].w;
    float width = t_p2[0].w;

    // Width axis from orientation (perpendicular to up)
    vec3 upN = normalize(t_up[0].xyz);
    vec3 wDir = normalize(vec3(-cos(theta), 0.0, sin(theta)));

    // Centerline point and tangent along the curve
    vec3 C = bezier3(p0, p1, p2, v);
    vec3 tan = normalize(mix(p1 - p0, p2 - p1, v));

    // Taper width slightly toward the tip
    float wScale = width * (1.0 - 0.2 * v);
    vec3 edge0 = C - wScale * wDir;
    vec3 edge1 = C + wScale * wDir;

    // Surface normal from tangent and width axis
    vec3 N = normalize(cross(tan, wDir));
    v_normal = N;
    v_param = v;

    // Interpolate across the ribbon
    // Simple shape function to bias toward center for nicer silhouette
    float s = u + 0.5 * v - u * v;
    vec3 pos = mix(edge0, edge1, s);

    gl_Position = camera.proj * camera.view * vec4(pos, 1.0);
}
