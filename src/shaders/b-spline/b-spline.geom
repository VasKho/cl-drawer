#version 400
layout (lines_adjacency) in;
layout (line_strip, max_vertices = 256) out;

mat4 mtx = mat4(-1.,  3., -3., 1.,
		 3., -6.,  3., 0.,
		-3.,  3.,  0., 0.,
		 1.,  0.,  0., 0.);

void main() {
  gl_Position = gl_in[0].gl_Position;
  EmitVertex();
  gl_Position = gl_in[1].gl_Position;
  EmitVertex();
  gl_Position = gl_in[2].gl_Position;
  EmitVertex();
  gl_Position = gl_in[3].gl_Position;
  EmitVertex();
  // vec2 p1 = gl_in[0].gl_Position.xy;
  // vec2 p4 = gl_in[1].gl_Position.xy;
  // vec2 p2 = gl_in[2].gl_Position.xy;
  // vec2 p3 = gl_in[3].gl_Position.xy;

  // if (p1 != p2) p2 *= 2;
  // if (p4 != p3) p3 *= 2;

  // vec4 first = mtx * vec4(p1.x, p2.x, p3.x, p4.x);
  // vec4 second = mtx * vec4(p1.y, p2.y, p3.y, p4.y);

  // for (float t = 0.; t < 1.; t += .01) {
  //   vec4 t_vec = vec4(pow(t, 3.), pow(t, 2.), t, 1.);
  //   gl_Position = vec4(dot(t_vec, first), dot(t_vec, second), 0., 1.);
  //   EmitVertex();
  // }
  EndPrimitive();
}
