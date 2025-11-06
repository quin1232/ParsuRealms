shader_type canvas_item;

void fragment() {
    vec2 uv = UV * 2.0 - 1.0; // Center UV (0,0) in middle
    float dist = length(uv);
    if (dist > 1.0) {
        discard; // Hide pixels outside circle
    }
    COLOR = texture(TEXTURE, UV);
}
