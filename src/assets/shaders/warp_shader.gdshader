shader_type spatial;
render_mode unshaded, depth_draw_always, cull_disabled; // NO LIGHTING!, "depth_draw_always" to 'fix' Z-ordering

uniform bool warp_ScreenSpace = false;
uniform sampler2D texture_albedo : source_color, filter_nearest;

void fragment() {
	vec2 uv = vec2(0.0);

	if(warp_ScreenSpace){
		uv = SCREEN_UV;
	}else{
		uv = UV;
	}

	// TODO: ADD NOISE SAMPLER INSTEAD OF USING TRIG?

	// TWEAK THE COEFFS AND/OR EQUATION FOR A DIFFERENT WARP PATTERN
	uv.x += sin(uv.y * 1.54 * PI + TIME/9.0) * cos(uv.y * 1.31 * PI + TIME/9.0) * 0.1;
	uv.y += cos(uv.x * 1.74 * PI + TIME/9.0) * -sin(uv.y * 1.64 * PI + TIME/9.0) * 0.1;

	vec4 color = texture(texture_albedo, uv * 2.0);

	ALBEDO = color.xyz;
	ALPHA = color.a;
}
