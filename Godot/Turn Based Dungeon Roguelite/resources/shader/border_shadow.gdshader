shader_type canvas_item;

// 중심 위치 (기본값: 화면 중앙)
uniform vec2 center = vec2(0.5, 0.5);

// 밝은 타원의 반지름
uniform float radius : hint_range(0.0, 1.0);

// 그라데이션 부드러움 정도
uniform float softness : hint_range(0.0, 1.0);

void fragment() {
    // 현재 픽셀 위치와 중심의 거리 계산
    float dist = distance(UV, center);

    // 타원형 그라데이션 계산
    float gradient = smoothstep(radius, radius + softness, dist);

    // 중앙은 완전히 투명, 바깥으로 갈수록 검은색 반투명
    COLOR = vec4(0.0, 0.0, 0.0, gradient);
}
