extern vec2 factor = vec2(1);
extern float clamp = 0.9;
const vec2 randVec = vec2(12.9898, 78.233);

// from http://www.ozone3d.net/blogs/lab/20110427/glsl-random-generator/
float rand(vec2 n)
{
  return 0.5 + 0.5 * fract(sin(dot(n.xy, randVec)) * 43758.5453);
}

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
{
  float grey = max(rand(tc * factor), clamp);
  return Texel(tex, tc) * vec4(grey, grey, grey, 1) * color;
}
