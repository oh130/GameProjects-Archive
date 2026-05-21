shader_type canvas_item;

uniform vec4 glass_tint : source_color = vec4(0.0, 0.0, 0.0, 0.5); // 어두운 유리 색상 (검정 + 반투명)

void fragment() {
    COLOR = glass_tint;
}
