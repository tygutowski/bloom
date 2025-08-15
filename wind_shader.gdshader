shader_type canvas_item;

// --- Per-frame inputs you set from script ---
uniform vec2 player_pos = vec2(0.0);   // player's global_position
uniform float player_dir = 0.0;         // -1 = moving left, +1 = moving right, 0 = idle
uniform float grow = 1.0;
// --- Per-instance inputs (set once, or when moved) ---
uniform vec2 instance_pos = vec2(0.0);  // this grass's global_position

// --- Tunables ---
uniform float player_radius = 36.0;     // influence radius (px)
uniform float player_push = 6.0;        // max player bend (px at top)
uniform float wind_strength = 0.0;      // >=0 push right, <=0 push left (px at top)
uniform float wind_hz = 1.2;            // cycles per second
uniform float tip_bias = 2.0;           // >1 keeps base more anchored
uniform float wobble_jitter = 0.5;      // 0..1 per-instance desync amount

// cheap hash for per-instance wind phase
float hash21(vec2 p){
	p = fract(p * vec2(0.1031, 0.11369));
	p += dot(p, p.yx + 33.33);
	return fract(p.x * p.y);
}

void vertex() {
	// Weight so the base is anchored and the tip moves most.
	float tip = pow(1.0 - UV.y, tip_bias);

	// Only the nearby instance bends from the player.
	float d = distance(instance_pos, player_pos);
	float near = smoothstep(player_radius, 0.0, d); // 1 near, 0 far

	// Player-caused bend
	float player_bend = player_push * player_dir * near * tip;

	// Wind bending
	float phase = hash21(instance_pos) * 6.28318 * wobble_jitter;
	float half_sine = max(sin(TIME * (6.28318 * wind_hz) + phase), 0.0);
	float wind_bend = sign(wind_strength) * abs(wind_strength) * half_sine * tip;

	// Horizontal bending
	float xoff = player_bend + wind_bend;
	VERTEX.x += xoff;

	float bottom = 5.0; // set to your mesh’s actual bottom Y position
	VERTEX.y = bottom + (VERTEX.y - bottom) * grow;





}