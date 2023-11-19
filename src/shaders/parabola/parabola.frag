#version 400
uniform vec4 vertexColor;

uniform vec4 param;

float dist(vec2 pt1, vec2 pt2, vec2 pt3) {
  vec2 v1 = pt2 - pt1;
  vec2 v2 = pt1 - pt3;
  vec2 v3 = vec2(v1.y, -v1.x);
  return abs(dot(v2, normalize(v3)));
}

float parabola_vert(in vec4 params) {
  vec2 coords = gl_FragCoord.xy;
  vec2 focus = params.zw;
  vec2 vertex = params.xy;
  float p = focus.y - vertex.y;
  float dx = coords.x - vertex.x;
  float dx_prev = dx-1.;
  float y_prev = (dx_prev*dx_prev)/(4.*p) + vertex.y;
  float y_perf = (dx*dx)/(4.*p) + vertex.y;    
  float d = dist(vec2(coords.x-1., y_prev), vec2(coords.x, y_perf), coords);
  return smoothstep(0., 1., d);
}

float parabola_hor(in vec4 params) {
  vec2 coords = gl_FragCoord.xy;
  vec2 focus = params.zw;
  vec2 vertex = params.xy;
  float p = focus.x - vertex.x;
  float dy = coords.y - vertex.y;
  float dy_prev = dy-1.;
  float x_prev = (dy_prev*dy_prev)/(4.*p) + vertex.x;
  float x_perf = (dy*dy)/(4.*p) + vertex.x;
  float d = dist(vec2(x_prev, coords.y-1.), vec2(x_perf, coords.y), coords);
  return smoothstep(0., 1., d);
}

void main() {
  vec2 vertex = param.xy;
  float dx1 = param.z - param.x;
  float dy1 = param.w - param.y;
  float dx = param.z - vertex.x;
  float dy = param.w - vertex.y;
  vec4 param_1;
  if (abs(dx1) > abs(dy1)) {
    param_1 = vec4(param.x+sign(dx), param.y, param.z+sign(dx), param.w);
    gl_FragColor = vec4(vec3(parabola_hor(param_1)), 1.);
  } else if (abs(dx1) < abs(dy1)) {
    param_1 = vec4(param.x, param.y+sign(dy), param.z, param.w+sign(dy));
    gl_FragColor = vec4(vec3(parabola_vert(param_1)), 1.);
  } else { discard; }
}
