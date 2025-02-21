shader_type canvas_item;

uniform float tolerance : hint_range(0.0, 1.0) = 0.2; // How strict the white removal is

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate how close the color is to pure white
    float diff = length(tex_color.rgb - vec3(1.0));

    // If the color is close to white, make it transparent
    if (diff < tolerance) {
        tex_color.a = 0.0;
    }

    COLOR = tex_color;
}