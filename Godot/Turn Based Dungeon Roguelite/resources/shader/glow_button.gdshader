shader_type canvas_item;
render_mode blend_mix;

uniform float transition : hint_range(0.0, 1.0); // 클릭 시 반짝이는 효과
uniform float fade_strength : hint_range(0.0, 1.0) = 0.8; // 흐려지는 정도
uniform float bg_alpha : hint_range(0.0, 1.0) = 0.4; // 배경 투명도

void fragment() {
    // 좌측(0)에서 우측(1)으로 갈수록 흐려짐
    float fade = smoothstep(1.0 - fade_strength, 1.0, UV.x);

    // 기본 검은색 배경 (투명도 조절 가능)
    vec4 base_color = vec4(0.0, 0.0, 0.0, bg_alpha);

    // Hover 시 금빛 배경
    vec4 hover_color = vec4(1.2, 1.0, 0.4, bg_alpha);

    // 기본 ↔ Hover 전환
    vec4 color = mix(base_color, hover_color, transition);

    // 흐려지는 효과 적용
    color.a *= (1.0 - fade);

    COLOR = color;
}
