shader_type canvas_item;
render_mode blend_mix, unshaded;

// -------- controls ----------
uniform float speed : hint_range(0.0, 3.0) = 0.5;
uniform float angle_deg : hint_range(-90.0, 90.0) = 25.0;
uniform float width : hint_range(0.02, 0.6) = 0.0;
uniform float softness : hint_range(0.0, 1.0) = 0.45;
uniform float intensity : hint_range(0.0, 3.0) = 0.5;
uniform vec4  shine_color : source_color = vec4(1.0, 0.95, 0.6, 1.0);
uniform bool  additive = true;
uniform float repeats : hint_range(1.0, 8.0) = 1.0;

// If >= 0 use 0..1 progress to drive the sweep; if <0 use TIME*speed.
uniform float progress = -1.0;
uniform float alpha_cutoff : hint_range(0.0, 1.0) = 0.001;

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    if (base.a <= alpha_cutoff) {
        discard;
    }

    // Rotate UVs around center to tilt the sweep
    vec2 p = UV - vec2(0.5);
    float a = radians(angle_deg);
    // Godot needs mat2 constructed from TWO vec2 columns:
    mat2 R = mat2(vec2(cos(a), -sin(a)),
                  vec2(sin(a),  cos(a)));
    vec2 r = R * p;

    // Sweep position
    float t = (progress < 0.0) ? fract(TIME * max(speed, 0.0001)) : clamp(progress, 0.0, 1.0);
    float sweep_phase = fract(t * repeats);
    float center = mix(-0.6, 0.6, sweep_phase);

    float dist = abs(r.x - center);

    float edge = smoothstep(0.0, width, dist);
    float band = 1.0 - edge;
    band = pow(band, mix(1.0, 3.0, softness));
    band *= base.a;

    vec3 result_rgb = base.rgb;
    vec3 shine = shine_color.rgb * band * intensity;

    if (additive) {
        result_rgb += shine;
    } else {
        result_rgb = mix(result_rgb, result_rgb + shine, band);
    }

    COLOR = vec4(result_rgb, base.a);
}
