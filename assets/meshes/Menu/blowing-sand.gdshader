shader_type spatial;
render_mode blend_mix, cull_back, specular_disabled;

uniform float time_scale = 0.05;
uniform float speed = 0.5;
uniform float swirl_speed = 0.2;
uniform float scale = 12.0;
uniform vec3 sand_color : source_color = vec3(0.90, 0.80, 0.60);
uniform float opacity = 0.6;
uniform int octaves = 5;
uniform float lacunarity = 2.0;
uniform float gain = 0.5;

float snoise_2d(vec2 v) {
    const vec4 C = vec4(
        0.211324865405187,
        0.366025403784439,
       -0.577350269189626,
        0.024390243902439
    );
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    vec2 i1;
    if (x0.x > x0.y) {
        i1 = vec2(1.0, 0.0);
    } else {
        i1 = vec2(0.0, 1.0);
    }

    vec2 x1 = x0 - i1 + C.xx;
    vec2 x2 = x0 - 1.0 + 2.0 * C.xx;

    i = mod(i, 289.0);
    vec3 p = ((i.y + vec3(0.0, i1.y, 1.0)) * 34.0 + 1.0) * (i.y + vec3(0.0, i1.y, 1.0));
    p = floor(mod(p, 289.0));
    p = ((p + i.x + vec3(0.0, i1.x, 1.0)) * 34.0 + 1.0) * (p + i.x + vec3(0.0, i1.x, 1.0));
    p = floor(mod(p, 289.0));

    vec3 x_ = floor(p * C.z);
    vec3 y_ = floor(p - 7.0 * x_);
    vec3 x2_ = x_ * 2.0 + 1.0;
    vec3 y2_ = y_ * 2.0 + 1.0;

    vec3 g = vec3(x2_.x + C.z, x2_.y + C.z, x2_.z + C.z);
    vec3 h = vec3(y2_.x + C.z, y2_.y + C.z, y2_.z + C.z);

    vec3 t0 = 0.5 - vec3(
        dot(x0, x0),
        dot(x1, x1),
        dot(x2, x2)
    );
    vec3 t1 = max(t0, 0.0);
    vec3 t2 = t1 * t1;
    vec3 t4 = t2 * t2;

    vec2 g0 = vec2(g.x, h.x);
    vec2 g1 = vec2(g.y, h.y);
    vec2 g2 = vec2(g.z, h.z);

    float n0 = t4.x * dot(g0, x0);
    float n1 = t4.y * dot(g1, x1);
    float n2 = t4.z * dot(g2, x2);

    return 40.0 * (n0 + n1 + n2);
}

float fbm(vec2 p, int octs, float lacun, float g) {
    float total = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;

    // WebGL loops must have static upper bounds
    for (int i = 0; i < 8; i++) {
        if (i >= octs) break;
        total += amplitude * snoise_2d(p * frequency);
        frequency *= lacun;
        amplitude *= g;
    }
    return total;
}

void fragment() {
    float t = TIME * time_scale;

    vec2 uv = UV * scale;
    uv.x += t * speed;
    uv.y += t * swirl_speed * 0.5 * sin(t * 0.3);

    float n = fbm(uv, octaves, lacunarity, gain);
    float n_01 = (n * 0.5) + 0.5;

    vec2 uv2 = uv;
    uv2.y -= t * speed * 0.4;
    float n2 = fbm(uv2, octaves, lacunarity, gain);
    float n2_01 = (n2 * 0.5) + 0.5;

    float combined = 0.6 * n_01 + 0.4 * n2_01;
    float brightness = mix(0.9, 1.1, combined);
    vec3 color_variation = sand_color * brightness;

    ALBEDO = color_variation;
    ALPHA = opacity * smoothstep(0.2, 1.0, combined);
    METALLIC = 0.0;
    ROUGHNESS = 1.0;
}
