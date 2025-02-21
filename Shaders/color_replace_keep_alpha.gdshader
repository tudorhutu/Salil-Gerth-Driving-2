shader_type canvas_item;

uniform vec4 target_color = vec4(1.0, 1.0, 1.0, 1.0); // Color to replace (default: White)
uniform vec4 replacement_color = vec4(1.0, 0.0, 0.0, 1.0); // New color (default: Red)
uniform float threshold = 0.1; // Tolerance for color matching

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Compute the difference between colors
    float diff = distance(tex_color.rgb, target_color.rgb);
    
    // If the difference is within the threshold, replace the color
    if (diff < threshold) {
        tex_color.rgb = replacement_color.rgb;
    }

    // Keep the original alpha
    COLOR = vec4(tex_color.rgb, tex_color.a);
}
