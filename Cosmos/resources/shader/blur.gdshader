shader_type canvas_item;

uniform float lod : hint_range(0.0, 5.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 modulate = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
    // modulate를 반영하여 밝기 및 알파값 조정
    color.rgb *= modulate.rgb;  // modulate의 RGB로 밝기 조정
    color.a *= modulate.a;      // modulate의 알파값으로 투명도 조정

    COLOR = color;
}
