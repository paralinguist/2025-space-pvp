shader_type canvas_item;
uniform sampler2D grad;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 col = texture(grad, vec2(UV.y, UV.x));
	COLOR = col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
