#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    float quant=32.0;
    vec4 pixColor = texture(tex, v_texcoord)*256.0;
    pixColor = floor(pixColor/quant)*quant;
    fragColor = pixColor / 256.0;
}
