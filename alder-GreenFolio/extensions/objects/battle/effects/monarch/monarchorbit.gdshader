shader_type particles;

// Keep this uniform so bone position can be set externally
uniform vec3 bone_pos = vec3(0.0);               // bone position offset
uniform float seed = 0.0;                        // per-system random seed
uniform float HEIGHT = 1.5;
// Constants for default behavior
const float ORBIT_SPEED  = 0.25;
const float RADIUS       = 1.0;
const float FLOAT_AMP    = 0.1;
const float FLOAT_SPEED  = 1.5;
const float SCALE_MIN    = 0.2;
const float SCALE_MAX    = 0.2;
const float FLAP_SPEED   = 5.5;
const float FLAP_AMP     = 1.0;
const float FLAP_JITTER  = 5.0;

// Deterministic pseudo-random function
float rand01(float x) {
    return fract(sin(x) * 43758.5453123);
}

void process() {
    float idx = float(INDEX);

    // Slightly varied orbit speed per particle
    float speed_variation = mix(0.9, 1.1, rand01(idx + 1.0 + seed));
    float particle_speed = ORBIT_SPEED * speed_variation;

    // Initial angle offset per particle
    float rand_angle = fract((idx + seed) * 0.62) * 6.28318530718;

    // Random vertical offset
    float rand_height = rand01(idx + 123.456 + seed);
    float y = mix(-HEIGHT * 0.5, HEIGHT * 0.5, rand_height);

    // Floating up/down motion
    y += sin(TIME * FLOAT_SPEED + idx + seed) * FLOAT_AMP;

    // Randomized radius (80%-100% of cylinder)
    float rand_radius = mix(RADIUS * 0.4, RADIUS, rand01(idx + 321.789 + seed));

    // Compute particle position around cylinder in local space
    float angle = TIME * particle_speed + rand_angle;
    vec3 p = vec3(cos(angle) * rand_radius,
                  y,
                  sin(angle) * rand_radius);

    // Apply bone position offset
    TRANSFORM[3].xyz = p + bone_pos;

    // Base particle scale
    float particle_scale = mix(SCALE_MIN, SCALE_MAX, rand01(idx + 456.789 + seed));

    // Fast, unsynced flapping with slight pause
    float flap_phase = rand01(idx + 789.123 + seed) * FLAP_JITTER * 6.283185;
    float flap_raw = sin(TIME * FLAP_SPEED + flap_phase);
    float flap = pow(abs(flap_raw), 0.6) * sign(flap_raw) * FLAP_AMP;

    // Apply scale and flapping
    TRANSFORM[0][0] = particle_scale * flap; // X = flapping width
    TRANSFORM[1][1] = particle_scale;        // Y scale
    TRANSFORM[2][2] = particle_scale;        // Z scale
}
