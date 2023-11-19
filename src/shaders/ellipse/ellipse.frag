#version 400
uniform vec4 vertexColor;

uniform vec4 param;

void main() {
  float a = distance(param.z, param.x);
  float b = distance(param.y, param.w);
  float dx = (gl_FragCoord.x - param.x);
  float dy = (gl_FragCoord.y - param.y);
  float eq = (dx*dx) / (a*a) + (dy*dy) / (b*b);

  float a1 = (a-1) * (a-1);
  float b1 = (b-1) * (b-1);
  float eq1 = (dx*dx) / a1 + (dy*dy) / b1;
  
  if (eq > 1. || eq1 < 1.) { discard; }
  gl_FragColor = vertexColor;
}
