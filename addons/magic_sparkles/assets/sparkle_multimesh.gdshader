shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D sparkle_atlas : filter_nearest, repeat_disable;

varying flat float v_frame_u;

void vertex() {
	v_frame_u = INSTANCE_CUSTOM.r;
}

void fragment() {
	vec2 atlas_uv = vec2(v_frame_u + UV.x * (7.0 / 27.0), UV.y * (7.0 / 7.0));
	vec4 tex = texture(sparkle_atlas, atlas_uv);
	COLOR = tex * COLOR;
}
