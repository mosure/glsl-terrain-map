// glsl terrain tutorial
// see `void main()` for tutorial steps

// glsl precision qualifier
precision mediump float;

#include "hsl.glsl"
#include "noise.glsl"

// viewport resolution (in pixels)
// mouse pixel coords. xy: current (if MLB down), zw: click
// shader playback time (in seconds)
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Step 0: Canonical Fragment Shader
void canonical_fragment_shader(vec2 st) {
    vec3 rgb = vec3(st.x, st.y, abs(sin(u_time)));

    // fragment shader output is a vec4 RGBA
    gl_FragColor = vec4(rgb, 1.0);
}

// Step 1: 2D Noise
vec3 step1_noise(vec2 st) {
    // uncomment lines with `st = ...` to follow along

    // select a larger region of noise (zoom out)
    // uncomment
    //st *= 10.0;

    // stretch the noise horizontally
    // uncomment
    //st *= vec2(1.0, 10.0);

    // snoise() returns values in the range [-1, 1] remap to [0, 1]
    return vec3(snoise(st) * 0.5 + 0.5);
}

// Step 2: Animating Noise
vec3 step2_animating_noise(vec2 st, float time) {
    // select a larger region of noise (zoom out)
    st *= 3.0;

    // use 2D space, 1D time as input to 3D noise
    vec3 space_time = vec3(st, time);

    // slow down time
    // uncomment
    //space_time = vec3(st, time * 0.1);

    // freeze time and move through space
    // uncomment
    //space_time = vec3(st + vec2(time, 0.0), 0.0);

    return vec3(snoise(space_time) * 0.5 + 0.5);
}

// Step 3: Noise with color
vec3 step3_terrain_color(vec2 st, float time) {
    st *= 4.0;
    time *= 0.5;

    float terrain = snoise(vec3(st, time * 0.1));

    vec3 color = vec3(0.0);

    // binary terrain coloring
    // notice aliasing artifacts
    if (terrain < 0.0) {
        color = vec3(0.0, 0.0, 1.0);
    } else {
        color = vec3(0.0, 1.0, 0.0);
    }

    // smooth terrain coloring
    // uncomment
    //color = mix(vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 0.0), terrain * 0.5 + 0.5);

    // hsl terrain coloring
    float hue = mix(0.7, 0.19, terrain * 0.5 + 0.5);
    vec3 hsl = vec3(hue, 1.0, 0.5);
    // uncomment
    //color = hsl2rgb(hsl);

    // TODO: add more color strata (and non-linear coloring)
    // TODO: gradient coloring

    // highlight terrain edges
    float edge_height = 0.0;
    float edge_radius = 0.02; // on slope 1 gradient
    float edge_highlight = smoothstep(edge_height - edge_radius, edge_height, terrain) -
        smoothstep(edge_height, edge_height + edge_radius, terrain);

    // uncomment
    color = mix(color, vec3(1.0, 0.0, 1.0), edge_highlight);

    return color;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;

    vec3 color = vec3(0.0);

    // --terrain tutorial steps--

    // 0:
    // canonical fragment shader displays a color square:
    // x-axis is red, y-axis is green, and time is blue
    // notice origin is bottom-left
    canonical_fragment_shader(st);
    return; // comment out to continue

    // 1:
    // generate 2d simplex noise and output in grayscale
    // uncomment the lines below to see the result
    //color = step1_noise(st);

    // 2:
    // generate 3d simplex noise over space and time
    // uncomment the lines below to see the result
    //color = step2_animating_noise(st, u_time);

    // 3:
    // color output based on noise height
    // uncomment the lines below to see the result
    //color = step3_terrain_color(st, u_time);

    // 4:
    // TODO:
    // - add more color strata (and non-linear coloring)
    // - uniform/mouse controls
    // - better terrain render (e.g. waves on the water, grass patches)
    // - more realistic terrain height (e.g. noise octaves)
    // - lighting
    // - biomes, rivers, trees

    gl_FragColor = vec4(color, 1.0);
}
