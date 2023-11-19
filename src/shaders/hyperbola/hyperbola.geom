#version 400
layout (lines) in;
layout (triangle_strip, max_vertices = 4) out;

uniform vec4 param;

void main() {
  vec4 center = gl_in[0].gl_Position;
  vec4 edge = gl_in[1].gl_Position;

  gl_Position = vec4(center.x - 2., center.y - 2., 0., 1.);
  EmitVertex();
  gl_Position = vec4(center.x - 2., center.y + 2., 0., 1.);
  EmitVertex();
  gl_Position = vec4(center.x + 2., center.y - 2., 0., 1.);
  EmitVertex();
  gl_Position = vec4(center.x + 2., center.y + 2., 0., 1.);
  EmitVertex();
  EndPrimitive();
}
