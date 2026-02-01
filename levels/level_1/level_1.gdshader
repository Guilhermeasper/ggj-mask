shader_type canvas_item;

uniform sampler2D noise_img : repeat_enable;
uniform float strength : hint_range(0.0, 1.0) = 0.5;
uniform float speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    // Criamos uma variação de tempo para o giz "vibrar" levemente (estilo animação manual)
    // Se quiser estático, pode remover o TIME
    vec2 uv_offset = vec2(floor(TIME * speed)) * 0.1;
    
    // Pegamos o valor do ruído
    float noise = texture(noise_img, UV + uv_offset).r;
    
    // Pegamos a cor original do ColorRect
    vec4 color = COLOR;
    
    // Aplicamos a "falha" do giz. 
    // Onde o ruído é baixo, a transparência aumenta
    float grain = smoothstep(0.2, 0.8, noise + (1.0 - strength));
    
    // Multiplicamos o alpha original pelo nosso grão
    color.a *= grain;
    
    COLOR = color;
}