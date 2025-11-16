shader_type particles;

uniform vec3 bone_pos = vec3(0.0);
uniform float seed = 2.0;
uniform int orbit_rings = 4;

const float ORBIT_SPEED  = 3.5;
const float RADIUS       = 1.3;
const float SCALE_MIN    = 0.25;
const float SCALE_MAX    = 0.25;

float rand01(float x) {
    return fract(sin(x) * 43758.5453123);
}

vec3 rotate_vec(vec3 v, vec3 axis, float theta) {
    return v*cos(theta) +
           cross(axis, v)*sin(theta) +
           axis*dot(axis, v)*(1.0 - cos(theta));
}

void process() {
    float idx = float(INDEX);

    float speed_variation = mix(0.9, 1.1, rand01(idx + 1.0 + seed));
    float particle_speed = ORBIT_SPEED * speed_variation;

    float rand_angle = rand01(idx + seed) * 6.28318530718;

    float rand_radius = mix(RADIUS * 0.8, RADIUS, rand01(idx + 321.789 + seed));

    float angle = TIME * particle_speed + rand_angle;
    vec3 base = vec3(cos(angle) * rand_radius,
                     0.0,
                     sin(angle) * rand_radius);

    int ring_id = int(mod(idx, float(orbit_rings)));

    // define tilts for rings
    float tilt_angles[4];
    tilt_angles[0] = radians(-40.0);
    tilt_angles[1] = radians(-15.0);
    tilt_angles[2] = radians(15.0);
    tilt_angles[3] = radians(40.0);

    float tilt = tilt_angles[ring_id];

    vec3 tilted = rotate_vec(base, vec3(1.0, 0.0, 0.0), tilt);

    TRANSFORM[3].xyz = tilted + bone_pos;

    float particle_scale = mix(SCALE_MIN, SCALE_MAX, rand01(idx + 456.789 + seed));
    TRANSFORM[0][0] = particle_scale;
    TRANSFORM[1][1] = particle_scale;
    TRANSFORM[2][2] = particle_scale;
}
