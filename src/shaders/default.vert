#version 400
in vec4 position;

mat4 view = mat4(
  1.0, 0.0, 0.0, 0.0,
  0.0, 1.0, 0.0, 0.0,
  0.0, 0.0, 1.0, 0.0,
  -1.0, -1.0, 0.0, 1.0
);

uniform mat4 x_rot;
uniform mat4 y_rot;
uniform mat4 z_rot;
uniform mat4 trans_scale;
uniform mat4 projection;
uniform vec2 u_resolution;

void main() {
  mat4 rot_matrix = x_rot*y_rot*z_rot;
  mat4 model = rot_matrix*trans_scale;
  gl_Position = projection*view*model*position;
}
