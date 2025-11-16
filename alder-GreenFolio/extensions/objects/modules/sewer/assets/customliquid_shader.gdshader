// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

/// New: scroll speed per second (X = sideways, Y = up/down)
uniform vec2 uv1_scroll = vec2(0.0, -0.2);

uniform float height_scale = 0.5;
uniform sampler2D displacement;

varying vec2 tex_position;
varying float vertex_displacement;

void vertex() {
	// Original UV transform
	UV = UV * uv1_scale.xy + uv1_offset.xy;

	// Keep displacement logic intact
	tex_position = VERTEX.xz / 2.0 + 0.5;
	float height = texture(displacement, tex_position).x;
	vertex_displacement = height * height_scale;
	VERTEX.y += vertex_displacement;
}

void fragment() {
	// Apply scroll to UVs during fragment stage
	vec2 scrolled_uv = UV + TIME * uv1_scroll;

	// Sample albedo with scrolled UVs
	vec4 albedo_tex = texture(texture_albedo, scrolled_uv);

	float darkening = vertex_displacement * 3.0;
	vec3 dark_vec = vec3(mix(1.0, 2.0, darkening));

	ALBEDO = albedo.rgb * albedo_tex.rgb * dark_vec.rgb;

	METALLIC = 0.0;
	SPECULAR = 0.0;
	ROUGHNESS = 0.0;
}
