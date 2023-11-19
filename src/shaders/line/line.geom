#version 400
layout (lines) in;
layout (line_strip, max_vertices = 2) out;
	       
// void draw_line_trivial() {
//   vec4 start = gl_in[0].gl_Position;
//   vec4 end = gl_in[1].gl_Position;
//   vec4 tmp = start;

//   if (start.x >= end.x) {
//     start = end;
//     end = tmp;
//   }

//   if (start.y == end.y) {
//     for (float x = start.x; x <= end.x; ++x) {
//       gl_Position = vec4(x, start.y, 0, 1);
//       EmitVertex();
//     }
//     EndPrimitive();
//   } else if (start.x == end.x) {
//     if (end.y >= start.y) {
//       for (float y = start.y; y <= end.y; ++y) {
// 	gl_Position = vec4(start.x, y, 0, 1);
// 	EmitVertex();
//       }
//     } else {
//       for (float y = start.y; y >= end.y; --y) {
// 	gl_Position = vec4(start.x, y, 0, 1);
// 	EmitVertex();
//       }
//     }
//     EndPrimitive();
//   } else if (abs(start.x - end.x) == abs(start.y - end.y)) {
//     if (end.y >= start.y) {
//       for (float x = start.x, float y = start.y; x <= end.x; y <= end.y; ++x, ++y) {
// 	gl_Position = vec4(x, y, 0, 1);
// 	EmitVertex();
//       }
//     } else {
//       for (float x = start.x, float y = start.y; x <= end.x; y >= end.y; ++x, --y) {
// 	gl_Position = vec4(x, y, 0, 1);
// 	EmitVertex();
//       }
//     }
//     EndPrimitive();
//   }
// }
	       
// void main() {
//   // draw_line_trivial();
//   vec4 start = gl_in[0].gl_Position;
//   vec4 end = gl_in[1].gl_Position;
//   float dx = end.x - start.x;
//   float dy = end.y - start.y;
//   float len = max(abs(dx), abs(dy));
//   float x_inc = dx / len;
//   float y_inc = dy / len;
//   float x = start.x;
//   float y = start.y
//   for (float i = 0.0; i <= len; ++i) {
//     gl_Position = vec4(trunc(x), round(y), 0.0, 1.0);
//     EmitVertex();
//     x += x_inc;
//     y += y_inc;
//   }
//   EndPrimitive();
// }

void main() {
  gl_Position = gl_in[0].gl_Position;
  EmitVertex();
  gl_Position = gl_in[1].gl_Position;
  EmitVertex();
  EndPrimitive();
}
