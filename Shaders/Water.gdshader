shader_type spatial;
render_mode cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture, source_color, repeat_disable;
uniform sampler2D normal_map_texture : hint_normal;
uniform vec3 water_color : source_color = vec3(0.0625, 0.1992, 0.3594);
uniform float index_of_refraction = 1.333;

//Wave information in order:  direction_x, direction_y, steepness, wavelenth
uniform vec4 wave_information_1 = vec4(1.0, 0, 0.5, 10.0);
uniform vec4 wave_information_2 = vec4(0, 1.0, 0.25, 20.0);
uniform vec4 wave_information_3 = vec4(1.0, 1.0, 0.15, 10.0);
uniform vec4 wave_information_4 = vec4(1.0, 1.0, 1.0, 1.0);


// Returns 1.0 if we can see above the water, 0.0 otherwise
float snells_window(vec3 normal, vec3 view, float ior) {
	float cos_theta = dot(normal, view);
	return step(sqrt(1.0 - cos_theta * cos_theta) * ior, 1.0);
}

// direction.y represents z axis (since it is 2D vec)
vec3 gerstner(vec3 vertex, vec4 wave, inout vec3 tangent, inout vec3 binormal){
//	Variables
	float k = 2.0 * PI / wave.w;
	float c = sqrt(9.8 / k);
	vec2 d = normalize(wave.xy);
	float f = k * ( dot(d, vertex.xz) - (c * TIME) );
	float a = wave[2] / k;

//	Adding to tangent var
	tangent += normalize(vec3(
		1.0 - d.x * d.x * wave.z * sin(f),
		d.x * wave.z * cos(f),
		-d.x * d.y * wave.z * sin(f)
	));
	
//	adding to binormal var
	binormal += vec3(
		-d.x * d.y * ( wave.z * sin(f) ),
		d.y * ( wave.z * cos(f) ),
		1.0 - d.y * d.y * ( wave.z * sin(f) )
	);
	
//	Return displacement vec3 from gerstner wave
	return vec3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	);
}

void vertex(){
	//VERTEX = gerstner(VERTEX, normalize(testdirection), TIME, speeed, steeepness, aamplitude, waavelength);
	//NORMAL = gerstner_normal(VERTEX, normalize(testdirection), TIME, speeed, steeepness, aamplitude, waavelength);
	vec3 tangent = vec3(1, 0, 0);
	vec3 binormal = vec3(0, 0, 1);
	vec3 output_vertex = VERTEX;
	
	output_vertex += gerstner(VERTEX, wave_information_1, tangent, binormal);
	output_vertex += gerstner(VERTEX, wave_information_2, tangent, binormal);
	output_vertex += gerstner(VERTEX, wave_information_3, tangent, binormal);
	
	NORMAL = normalize(cross(binormal, tangent));
	VERTEX = output_vertex;
}

void fragment() {
	ROUGHNESS = 0.0;

	// Basic waves
	float time = TIME * 0.05;
	vec3 normal_sample_1 = texture(normal_map_texture, UV + vec2(-1, 1) * time).xyz * 2.0 - 1.0;
	vec3 normal_sample_2 = texture(normal_map_texture, -UV + vec2(0, 1) * time).xyz * 2.0 - 1.0;
	vec3 normal_map = vec3(normal_sample_1.xy + normal_sample_2.xy, 0.0);
	
	// Set NORMAL directly since we need to use it later
	NORMAL_MAP_DEPTH = 1.0;
	normal_map.z = sqrt(max(0.0, 1.0 - dot(normal_map.xy, normal_map.xy)));
	NORMAL = normalize(mix(NORMAL, TANGENT * normal_map.x + BINORMAL * normal_map.y + NORMAL * normal_map.z, NORMAL_MAP_DEPTH));
	
	// Screen distortion
	vec2 distorted_uv = SCREEN_UV - normal_map.xy * 2.0 / length(VERTEX);
	ALBEDO = texture(screen_texture, distorted_uv).rgb;
	
	// Apply Snell's window mask to water surface when viewed from below
	if(!FRONT_FACING) {
		float mask = snells_window(NORMAL, VIEW, index_of_refraction);
		ALBEDO = mix(water_color, ALBEDO, mask);
		RADIANCE = vec4(vec3(0.0), mask);
		IRRADIANCE = vec4(vec3(1.0), mask);
	}
}