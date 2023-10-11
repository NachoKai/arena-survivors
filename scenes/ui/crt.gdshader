shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv *= 1.05; // Slightly reduced multiplier for subtle effect
    uv.x *= 1.0 + pow((abs(uv.y) / 6.0), 2.0); // Adjusted for subtlety
    uv.y *= 1.0 + pow((abs(uv.x) / 5.0), 2.0); // Adjusted for subtlety
    uv  = (uv / 2.0) + 0.5;
    uv =  uv * 0.96 + 0.02; // Fine-tuned for subtlety
    return uv;
}

void fragment() {
    vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 q = FRAGCOORD.xy / iResolution.xy;
    vec2 uv = q;
    uv = curve( uv );
    vec3 col;
    float x =  sin(0.2*TIME+uv.y*15.0)*sin(0.5*TIME+uv.y*21.0)*sin(0.2+0.22*TIME+uv.y*23.0)*0.0012; // Reduced sinusoidal intensity

    col.r = texture(screen_texture,vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
    col.g = texture(screen_texture,vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
    col.b = texture(screen_texture,vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
    col.r += 0.06*texture(screen_texture,0.75*vec2(x+0.015, -0.017)+vec2(uv.x+0.001,uv.y+0.001)).x; // Adjusted multiplier
    col.g += 0.04*texture(screen_texture,0.75*vec2(x+-0.014, -0.014)+vec2(uv.x+0.000,uv.y-0.002)).y; // Adjusted multiplier
    col.b += 0.06*texture(screen_texture,0.75*vec2(x+-0.012, -0.012)+vec2(uv.x-0.002,uv.y+0.000)).z; // Adjusted multiplier
    col = clamp(col*0.6+0.4*col*col*1.0,0.0,1.0);

    float vig = (0.0 + 1.0*6.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y)); // Reduced vignette effect
    
    col *= vec3(pow(vig,0.25)); // Adjusted power

    col *= vec3(0.98,1.02,0.98); // Fine-tuned color balance
    col *= 2.0; // Adjusted multiplier

    float scans = clamp( 0.2+0.2*sin(2.0*TIME+uv.y*iResolution.y*1.5), 0.0, 1.0); // Reduced scans effect
    float s = pow(scans,1.7);
    
    col = col*vec3( 0.3+0.7*s) ; // Adjusted multiplier

    col *= 1.0+0.005*sin(110.0*TIME);

    if (uv.x < 0.0 || uv.x > 1.0)
        col *= 0.0;
    if (uv.y < 0.0 || uv.y > 1.0)
        col *= 0.0;

    col*=1.0-0.65*vec3(clamp((mod(FRAGCOORD.x, 2.0)-1.0)*2.0,0.0,1.0));

    COLOR = vec4(col,1.0);
}
