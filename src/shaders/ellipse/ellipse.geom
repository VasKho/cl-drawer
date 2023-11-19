#version 400
layout (lines) in;
layout (triangle_strip, max_vertices = 4) out;

uniform vec2 u_resolution;

void main() {
  vec4 center = gl_in[0].gl_Position;
  vec4 edge = gl_in[1].gl_Position;
  float rx = distance(center.x, edge.x)+0.01;
  float ry = distance(center.y, edge.y)+0.01;
  gl_Position = vec4(center.x-rx, center.y-ry, 0.0, 1.0);
  EmitVertex();
  gl_Position = vec4(center.x-rx, center.y+ry, 0.0, 1.0);
  EmitVertex();
  gl_Position = vec4(center.x+rx, center.y-ry, 0.0, 1.0);
  EmitVertex();
  gl_Position = vec4(center.x+rx, center.y+ry, 0.0, 1.0);
  EmitVertex();
  EndPrimitive();
}
