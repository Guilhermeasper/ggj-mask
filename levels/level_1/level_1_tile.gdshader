shader_type canvas_item;

// Textura de ruído para a distorção (use a mesma do shader anterior se quiser consistência)
uniform sampler2D noise_tex : repeat_enable;
uniform float strength : hint_range(0.0, 0.1) = 0.01; // Intensidade do "tremido"
uniform float softness : hint_range(0.0, 1.0) = 0.2;  // O quanto arredonda a borda
uniform float speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    // 1. Criar um deslocamento baseado no ruído e no tempo
    vec2 time_offset = vec2(floor(TIME * speed)) * 0.1;
    vec2 noise_val = texture(noise_tex, screen_uv + time_offset).rg;
    
    // 2. Distorcer a leitura da textura para entortar as bordas
    vec2 distorted_uv = SCREEN_UV + (noise_val - 0.5) * strength;
    
    // 3. Pegar a cor da tela (do que o CanvasGroup renderizou)
    vec4 screen_color = texture(SCREEN_TEXTURE, distorted_uv);
    
    // 4. "Amaciar" a borda usando o canal alpha
    // O smoothstep faz com que a transição do transparente para o opaco não seja brusca
    float alpha = smoothstep(0.0, softness, screen_color.a);
    
    COLOR = vec4(screen_color.rgb, alpha);
}