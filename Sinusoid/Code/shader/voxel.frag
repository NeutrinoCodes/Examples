/// @file

#version 460 core

uniform mat4 V_mat;                                                             // View matrix.
uniform mat4 P_mat;                                                             // Projection matrix.

in  vec4 color;                                                                 // Voxel color.
in  vec2 quad;
in float AR_quad;                                                               // Billboard quad aspect ratio.

out vec4 fragment_color;                                                        // Fragment color.

void main(void)
{
  
  float k1;                                                                     // Blooming coefficient.
  float k2;                                                                     // Smoothness coefficient.
  float k3;                                                                     // Smoothness coefficient.
  float R;

  R = length(quad);

  k1 = 1.0 - smoothstep(0.0, 0.5, R);                                           // Computing blooming coefficient...
  k2 = 1.0 - smoothstep(0.0, 0.1, R);                                           // Computing smoothing coefficient...
  k3 = 1.0 - smoothstep(0.2, 0.3, R);                                           // Computing smoothing coefficient...

  if (k1 == 0.0)
  {
    discard;                                                                    // Discarding fragment point...
  }

  fragment_color = vec4(0.8*vec3(k2, 1.2*k3, k1) + color.rgb, 0.2 + k1);        // Setting fragment color...  
}