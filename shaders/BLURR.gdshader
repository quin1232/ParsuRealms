
shader_type canvas_item;

uniform float blur_size : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    vec2 size_tex = vec2(textureSize(TEXTURE, 0));
    vec4 col = vec4(0.0);
    float total = 0.0;

    // Sample multiple times around pixel for blur
    for (float x = -blur_size; x <= blur_size; x++) {
        for (float y = -blur_size; y <= blur_size; y++) {
            float weight = 5.0 - length(vec2(x, y)) / blur_size;
            weight = max(weight, 0.0);
            col += texture(TEXTURE, UV + vec2(x, y) / size_tex) * weight;
            total += weight;
        }
    }

    COLOR = col / total;
}
