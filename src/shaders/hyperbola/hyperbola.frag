#version 400
uniform vec4 vertexColor;

uniform vec4 param;
uniform vec2 u_resolution;

bool hyperbola(in float a, in float b) {
  float dx = gl_FragCoord.x - param.x;
  float dy = gl_FragCoord.y - param.y;
  return (dy*dy) / (a*a) - (dx*dx) / (b*b) > 1 || (dy*dy) / (a*a) - (dx*dx) / (b*b) < 0.85;
}

void main() {
  vec2 center = param.xy / u_resolution;
  vec2 edge = param.zw / u_resolution;
  float a = distance(center.x, edge.x);
  float b = distance(center.y, edge.y);

  float dx = (gl_FragCoord.x - param.x) / u_resolution.x;
  float dy = (gl_FragCoord.y - param.y) / u_resolution.y;

  float v = (dy*dy) / (a*a) - (dx*dx) / (b*b) - 1;

  float f = smoothstep(0., 1., v);
  gl_FragColor = vec4(vec3(f), 1.);
}
