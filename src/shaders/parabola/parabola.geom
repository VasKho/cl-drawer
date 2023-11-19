#version 400
layout (lines) in;
layout (triangle_strip, max_vertices = 4) out;

uniform vec2 u_resolution;
uniform vec4 param;

// Should wait for rotations
// void main() {
//   vec2 vertex = gl_in[0].gl_Position.xy;
//   vec2 focus = gl_in[1].gl_Position.xy - vertex;
//   vec2 i = vec2(1, 0);

//   float cos_a = dot(focus, i) / length(focus);
//   float sin_a = -sqrt(1 - cos_a*cos_a);
//   mat2 r = mat2(cos_a, sin_a, -sin_a, cos_a);

//   vec2 bot_left = vec2(vertex.x - 1., vertex.y);
//   vec2 top_left = vec2(vertex.x - 1., vertex.y + 1.);
//   vec2 bot_right = vec2(vertex.x + 1., vertex.y);
//   vec2 top_right = vec2(vertex.x + 1., vertex.y + 1.);
  
//   gl_Position = vec4(vec2(r*bot_left)*aspect, 0., 1.);
//   EmitVertex();
//   gl_Position = vec4(vec2(r*top_left)*aspect, 0., 1.);
//   EmitVertex();
//   gl_Position = vec4(vec2(r*bot_right)*aspect, 0., 1.);
//   EmitVertex();
//   gl_Position = vec4(vec2(r*top_right)*aspect, 0., 1.);
//   EmitVertex();
//   EndPrimitive();
// }

void main() {
  vec2 vertex = gl_in[0].gl_Position.xy;
  vec2 focus = gl_in[1].gl_Position.xy;

  float dx = param.z - param.x;
  float dy = param.w - param.y;

  vec2 p_1, p_2, p_3, p_4;
  
  if (abs(dx) > abs(dy)) {
    if (dx > 0.) {
      p_1 = vec2(vertex.x, vertex.y + 2.);
      p_2 = vec2(vertex.x + 2., vertex.y + 2.);
      p_3 = vec2(vertex.x, vertex.y - 2.);
      p_4 = vec2(vertex.x + 2., vertex.y - 2.);
    } else {
      p_1 = vec2(vertex.x, vertex.y - 2.);
      p_2 = vec2(vertex.x - 2., vertex.y - 2.);
      p_3 = vec2(vertex.x, vertex.y + 2.);
      p_4 = vec2(vertex.x - 2., vertex.y + 2.);
    }
  } else {
    if (dy > 0.) {
      p_1 = vec2(vertex.x - 2., vertex.y);
      p_2 = vec2(vertex.x - 2., vertex.y + 2.);
      p_3 = vec2(vertex.x + 2., vertex.y);
      p_4 = vec2(vertex.x + 2., vertex.y + 2.);
    } else {
      p_1 = vec2(vertex.x + 2., vertex.y);
      p_2 = vec2(vertex.x + 2., vertex.y - 2.);
      p_3 = vec2(vertex.x - 2., vertex.y);
      p_4 = vec2(vertex.x - 2., vertex.y - 2.);
    }
  }
  
  gl_Position = vec4(vec2(p_1), 0., 1.);
  EmitVertex();
  gl_Position = vec4(vec2(p_2), 0., 1.);
  EmitVertex();
  gl_Position = vec4(vec2(p_3), 0., 1.);
  EmitVertex();
  gl_Position = vec4(vec2(p_4), 0., 1.);
  EmitVertex();
  EndPrimitive();
}
