shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// Assign GradientTexture2D resources here
uniform sampler2D GRADIENT_A : filter_linear; // e.g., green → yellow
uniform sampler2D GRADIENT_B : filter_linear; // e.g., blue  → orange

uniform float value : hint_range(0.0, 1.0, 0.001) = 0.0; // you change this live
uniform float bw_threshold : hint_range(0.0, 1.0) = 0.5;    // split point between A/B
uniform float alpha_eps = 0.001;

void fragment() {
    vec4 src = texture(SCREEN_TEXTURE, SCREEN_UV);

    if (src.a <= alpha_eps) {
        COLOR = vec4(0.0); // keep transparent pixels transparent
        discard;
    }

    // Decide which bucket the source pixel is in (black vs white) by luminance
    float lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));
    bool use_a = lum >= bw_threshold;

    // Sample both gradients at the SAME position (your dial)
    vec4 col_a = texture(GRADIENT_A, vec2(value, 0.5));
    vec4 col_b = texture(GRADIENT_B, vec2(value, 0.5));

    COLOR = use_a ? col_a : col_b;
}
