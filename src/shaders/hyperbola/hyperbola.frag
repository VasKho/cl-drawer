#version 400
uniform vec4 vertexColor;

uniform vec4 param;

float dist(vec2 pt1, vec2 pt2, vec2 pt3) {
  vec2 v1 = pt2 - pt1;
  vec2 v2 = pt1 - pt3;
  vec2 v3 = vec2(v1.y, -v1.x);
  return abs(dot(v2, normalize(v3)));
}

float hyperbola_vert(in vec2 center, in float a, in float b) {
  vec2 coords = gl_FragCoord.xy;
  float s = (coords.y > center.y)? 1.: -1.;
  float dx = coords.x - center.x;
  float d = s*a*sqrt(1. + (dx*dx)/(b*b));
  float y_perf = center.y + d;
  float dx_prev = dx - 1.;
  float d_prev = s*a*sqrt(1. + (dx_prev*dx_prev)/(b*b));
  float y_prev = center.y + d_prev;
  float err = dist(vec2(coords.x-1., y_prev), vec2(coords.x, y_perf), coords);
  return smoothstep(0., 1., err);
}

void main() {
  vec2 center = param.xy;
  vec2 edge = param.zw;
  float a = distance(center.x, edge.x);
  float b = distance(center.y, edge.y);
  if (a == 0. || b == 0.) { discard; }
  gl_FragColor = vec4(vec3(vertexColor.xyz), 1.-hyperbola_vert(center, a, b));
}
