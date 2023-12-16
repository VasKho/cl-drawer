#version 400
layout (triangles) in;
layout (triangle_strip, max_vertices = 256) out;

void main() {
  for (int n = 0; n < 3; ++n) {
    gl_Position = gl_in[n].gl_Position;
    EmitVertex();
  }
  EndPrimitive();
}
