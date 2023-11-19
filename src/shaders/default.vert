#version 400
in vec4 position;

mat4 model = mat4(1.0);

mat4 view = mat4(
  1.0, 0.0, 0.0, 0.0,
  0.0, 1.0, 0.0, 0.0,
  0.0, 0.0, 1.0, 0.0,
  -1.0, -1.0, 0.0, 1.0
);

uniform mat4 projection;
uniform vec2 u_resolution;

void main() {
  gl_Position = projection*view*model*position;
}
