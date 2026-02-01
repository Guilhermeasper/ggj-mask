shader_type canvas_item;

// No Godot 4, precisamos desta linha para ler o que está "atrás" (o TileMap)
uniform sampler2D screen_texture : hint_screen_texture, repeat_enable, filter_linear;
uniform sampler2D noise_tex : repeat_enable;

uniform float strength : hint_range(0.0, 0.1) = 0.01;
uniform float softness : hint_range(0.0, 1.0) = 0.2;
uniform float speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    // 1. Criar o deslocamento (corrigido para SCREEN_UV maiúsculo)
    vec2 time_offset = vec2(floor(TIME * speed)) * 0.1;
    vec2 noise_val = texture(noise_tex, SCREEN_UV + time_offset).rg;
    
    // 2. Distorcer a coordenada de leitura
    vec2 distorted_uv = SCREEN_UV + (noise_val - 0.5) * strength;
    
    // 3. Ler a cor usando a textura da tela declarada acima
    vec4 screen_color = texture(screen_texture, distorted_uv);
    
    // 4. Suavizar as bordas (Alpha Erosion)
    float alpha = smoothstep(0.0, softness, screen_color.a);
    
    // Manter a cor original do tile, mas com o novo alpha suave
    COLOR = vec4(screen_color.rgb, screen_color.a * alpha);
}