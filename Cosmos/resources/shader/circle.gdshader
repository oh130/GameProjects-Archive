shader_type canvas_item;

// 타원의 색상
uniform vec4 ellipse_color = vec4(1.0, 1.0, 1.0, 1.0); // 기본값: 흰색
// 타원의 가운데가 뚫려있는지 여부
uniform bool hollow_center = false;
// 타원의 정도 (1.0 = 원, 0.5 = 타원, 2.0 = 더 길쭉한 타원)
uniform float ellipse_strength : hint_range(0.1, 5.0) = 1.0;
// 타원의 내부 반경 (hollow_center가 true일 때만 사용)
uniform float inner_radius : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // UV 좌표를 -1에서 1 사이로 변환 (중심을 기준으로)
    vec2 uv = (UV - 0.5) * 2.0;

    // 타원의 정도를 적용
    uv.y /= ellipse_strength;

    // 현재 픽셀이 타원 안에 있는지 확인
    float distance_from_center = length(uv);
    float alpha = smoothstep(1.0, 0.99, distance_from_center); // 외곽선 부드럽게 처리

    // 가운데가 뚫려있는지 확인
    if (hollow_center) {
        float inner_alpha = smoothstep(inner_radius, inner_radius + 0.01, distance_from_center);
        alpha *= inner_alpha;
    }

    // 최종 색상 설정
    COLOR = vec4(ellipse_color.rgb, ellipse_color.a * alpha);
}