shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float vignette_intensity : hint_range(0.0, 3.0) = 1.25;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float pulse_speed : hint_range(0.0, 20.0) = 4.0;
uniform float pulse_amount : hint_range(0.0, 0.5) = 0.04;

// Chromatic Aberration & Distortion
uniform float aberration_amount : hint_range(0.0, 0.05) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 centered_uv = UV - vec2(0.5);
	float dist = length(centered_uv);
	
	// Vignette pulse calculation
	float pulse = sin(TIME * pulse_speed) * pulse_amount;
	float effective_intensity = vignette_intensity + pulse;
	float vignette = smoothstep(0.12, 0.58, dist * effective_intensity);
	
	// Calculate Chromatic Aberration offset based on distance from center & opacity
	float offset = dist * aberration_amount * vignette_opacity;
	
	// Sample screen texture with RGB split (chromatic aberration)
	float r = texture(screen_texture, uv + vec2(offset, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(offset, 0.0)).b;
	vec3 screen_col = vec3(r, g, b);
	
	// Calculate edge darkening factor
	float dark_factor = clamp(vignette * vignette_opacity * vignette_color.a, 0.0, 1.0);
	vec3 final_color = mix(screen_col, vignette_color.rgb, dark_factor);
	
	// Output final composited color (use non-zero alpha when opacity > 0 so Godot renders screen effect properly)
	float alpha_out = clamp(vignette_opacity * 2.0, 0.0, 1.0);
	COLOR = vec4(final_color, alpha_out);
}
