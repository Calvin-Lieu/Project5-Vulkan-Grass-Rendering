#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// Declare fragment shader inputs (from tessellation evaluation shader)
layout(location = 0) in vec3 fragPos;
layout(location = 1) in vec3 fragNormal;
layout(location = 2) in vec2 fragUV;

layout(location = 0) out vec4 outColor;

void main() {
    // Normalize the normal vector
    vec3 normal = normalize(fragNormal);
    
    // Simple directional light
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    
    // Basic lambertian lighting
    float lambertian = max(dot(normal, lightDir), 0.0);
    
    vec3 grassColor = mix(vec3(0.1, 0.4, 0.1), vec3(0.2, 0.6, 0.2), fragUV.y);
    
    // Add minimal ambient lighting
    vec3 ambient = grassColor * 0.3;
    vec3 diffuse = grassColor * lambertian;
    
    vec3 finalColor = ambient + diffuse;
    
    // Output final color
    outColor = vec4(finalColor, 1.0);
}