shader_type canvas_item;

varying vec4 v_modulate;

uniform float tint_strength : hint_range(0.0, 1.0) = 0.45;
uniform vec3 tint_color : source_color = vec3(1.0, 0.45, 0.8);
uniform float brightness : hint_range(-0.5, 0.5) = 0.08;

void vertex() {
    v_modulate = COLOR;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    vec3 tinted = mix(tex.rgb, tint_color, tint_strength);

    tinted += vec3(brightness);

    vec3 final_color = clamp(tinted, vec3(0.0), vec3(1.0));

    final_color *= v_modulate.rgb;
    float final_alpha = tex.a * v_modulate.a;

    COLOR = vec4(final_color, final_alpha);
}
