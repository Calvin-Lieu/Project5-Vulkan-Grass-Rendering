#version 450
#extension GL_ARB_separate_shader_objects : enable

// Varyings
layout(location = 0) in vec3 v_normal;
layout(location = 1) in float v_param;

layout(location = 0) out vec4 outColor;

void main()
{
    vec3 N = normalize(v_normal);

    // Simple one-bounce diffuse from a sky-like direction
    vec3 L = normalize(vec3(0.3, 0.8, 0.5));
    float ndotl = max(dot(N, L), 0.0);

    // Chromatic variation from base to tip
    vec3 baseCol = vec3(49.0/255.0, 125.0/255.0, 54.0/255.0);
    vec3 tipCol  = vec3(162.0/255.0, 214.0/255.0, 124.0/255.0);
    vec3 albedo  = mix(baseCol, tipCol, clamp(v_param, 0.0, 1.0));

    // Ambient + diffuse
    vec3 ambient = vec3(0.12, 0.14, 0.12);
    vec3 color   = ambient + albedo * (0.7 + 0.25 * ndotl);

    outColor = vec4(color, 1.0);
}
