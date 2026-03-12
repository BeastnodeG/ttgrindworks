// HSV to RGB from https://www.rapidtables.com/convert/color/hsv-to-rgb.html

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded, shadows_disabled;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform sampler2D mask_texture : source_color, hint_default_black;
uniform float speed : hint_range(0., 10.) = 0.145;
uniform float angle : hint_range(0., 360.) = 153.;
uniform float scale : hint_range(0.1, 10.0) = 0.1;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]
	);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
		vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);
}

void fragment() {
	float spatial = (UV.x * cos(radians(angle)) - UV.y * sin(radians(angle))) * scale;
	float hue = fract(spatial + TIME * speed);

	// Remap hue so each color gets equal perceived time.
	// Each segment boundary is spaced by how long that color needs to
	// linger to feel visually equal to the others.
	// Breakpoints: red, yellow, green, cyan, blue, violet
	const float[7] IN  = float[7](0.0,  0.1667, 0.3333, 0.5,    0.6667, 0.8333, 1.0);
	const float[7] OUT = float[7](0.0,  0.21,   0.37,   0.5,    0.63,   0.79,   1.0);
	float remapped = hue;
	for (int i = 0; i < 6; i++) {
		if (hue >= IN[i] && hue < IN[i + 1]) {
			float t = (hue - IN[i]) / (IN[i + 1] - IN[i]);
			remapped = mix(OUT[i], OUT[i + 1], t);
			break;
		}
	}
	hue = remapped;

	float x = 1. - abs(mod(hue / (1. / 6.), 2.) - 1.);

	vec3 rainbow;
	if (hue < 1. / 6.) {
		rainbow = vec3(1., x, 0.);
	} else if (hue < 1. / 3.) {
		rainbow = vec3(x, 1., 0.);
	} else if (hue < 0.5) {
		rainbow = vec3(0., 1., x);
	} else if (hue < 2. / 3.) {
		rainbow = vec3(0., x, 1.);
	} else if (hue < 5. / 6.) {
		rainbow = vec3(x, 0., 1.);
	} else {
		rainbow = vec3(1., 0., x);
	}

	vec4 color = texture(albedo_texture, UV);
	float mask = texture(mask_texture, UV).a;

	float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 rainbow_shaded = rainbow * luma;

	ALBEDO = mix(color.rgb, rainbow_shaded, mask);
	ALPHA = color.a;
}
