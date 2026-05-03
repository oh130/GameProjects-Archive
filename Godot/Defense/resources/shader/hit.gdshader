shader_type canvas_item;

uniform float alpha_factor = 0.0;

void fragment() {
    vec4 previous_color = texture(TEXTURE, UV);
    vec4 white_color = vec4(1.0, 1.0, 1.0, alpha_factor * previous_color.a);
    vec4 new_color = mix(previous_color, white_color, alpha_factor);

    COLOR = new_color;
}
