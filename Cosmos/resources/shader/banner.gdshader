shader_type canvas_item;

void fragment() {
    // 위쪽은 투명, 아래쪽으로 갈수록 검은색 반투명
    float alpha = mix(0.0, 0.8, UV.y); // UV.y는 위(0)에서 아래(1)로 갈수록 증가
    COLOR = vec4(0.0, 0.0, 0.0, alpha); // 검은색 (R=0, G=0, B=0)에 alpha 값 적용
}