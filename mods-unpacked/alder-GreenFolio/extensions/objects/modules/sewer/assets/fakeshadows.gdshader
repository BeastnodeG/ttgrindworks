shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;

// Toontown-style prebaked edge shading
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float edge_softness : hint_range(0.001, 0.3) = 0.05;

varying vec3 world_normal;
varying vec3 local_position;

void vertex() {
    world_normal = (MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
    local_position = VERTEX;
}

void fragment() {
    // Preserve the original material's properties
    vec3 base_color = ALBEDO;

    // Create edge detection based on surface curvature
    // Use the dot product of normal with up vector to detect horizontal edges
    // and position-based gradients for vertical edges
    vec3 up = vec3(0.0, 1.0, 0.0);
    float horizontal_edge = abs(dot(normalize(world_normal), up));

    // Create position-based edge detection for geometric edges
    vec3 pos_gradient = abs(dFdx(local_position)) + abs(dFdy(local_position));
    float geometric_edge = length(pos_gradient);

    // Combine both edge detection methods
    float edge_factor = max(1.0 - horizontal_edge, geometric_edge * 10.0);

    // Apply threshold and smoothing
    edge_factor = smoothstep(edge_threshold - edge_softness, edge_threshold + edge_softness, edge_factor);

    // Mix the base material color with edge color
    ALBEDO = mix(base_color, edge_color.rgb, edge_factor);
}