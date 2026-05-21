shader_type canvas_item;

void fragment() {
    // 현재 픽셀의 UV 좌표
    vec2 uv = vec2(UV.x - (TIME), UV.y);
	vec4 color = texture(TEXTURE, uv);
	COLOR = color;
}