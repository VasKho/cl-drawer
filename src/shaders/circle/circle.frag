#version 400
uniform vec4 vertexColor;

uniform vec4 param;

void main() {
  float rad = distance(param.x, param.z);
  float dist = distance(gl_FragCoord.xy, param.xy);
  if (dist > rad || dist < rad-1.) { discard; }
  gl_FragColor = vertexColor;
}
