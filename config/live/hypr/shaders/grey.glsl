#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    float gray = 0.0;
    gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    fragColor = vec4(vec3(0.7*gray,0.9*gray,gray), pixColor.a);
}

