shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform vec4 PRIMARY_COLOR : hint_selection;
uniform vec4 SECONDARY_COLOR : hint_color; 

void fragment() {
	vec4 source = texture(SCREEN_TEXTURE, UV);

	if (source == vec4(1.0, 1.0, 1.0, 1.0)) { // white
		COLOR = PRIMARY_COLOR;
	}
	if (source == vec4(0.0, 0.0, 0.0, 1.0)) { //black
		COLOR = SECONDARY_COLOR;
	}
	if (source.a == 0.0) { // transparent (black)
		COLOR = SECONDARY_COLOR;
	}
}
