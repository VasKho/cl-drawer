#version 400
layout (lines) in;
layout (line_strip, max_vertices = 256) out;

void main() {
  for (int n = 0; n < 2; ++n) {
    gl_Position = gl_in[n].gl_Position;
    EmitVertex();
  }
  EndPrimitive();
}
