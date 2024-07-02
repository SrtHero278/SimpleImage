shader_type canvas_item;

uniform float gridSize = 40.0;
uniform vec2 imgSize;
uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;

void fragment() {
	float daX = mod(UV.x * imgSize.x, gridSize);
	float daY = mod(UV.y * imgSize.y, gridSize);
	daX = abs(step(daY, gridSize * 0.5) * gridSize - daX);
	COLOR.rgb = mix(color1, color2, step(daX, gridSize * 0.5));
	COLOR.a = 1.0;
}