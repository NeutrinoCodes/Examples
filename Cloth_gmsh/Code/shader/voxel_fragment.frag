/// @file

#version 410 core

in  vec4 voxel_color;                                                           // Voxel color.
in  vec4 voxel_center; 
in  vec4 voxel_point;
out vec4 fragment_color;                                                        // Fragment color.

void main(void)
{
  vec2 P;                                                                       // 2D fragment coordinates of the voxel.
  float R;                                                                      // Radius of the voxel.
  float k1;                                                                      // Smoothness coefficient.
  float k2;
  float k3;

  P = gl_PointCoord;                                                            // Getting fragment coordinates...
  R = distance(P, vec2(0.5, 0.5));                                              // Computing voxel radius...
  k1 = 1.0 - smoothstep(0.0, 0.5, R);                                            // Computing smoothness coefficient...
  k2 = 1.0 - smoothstep(0.0, 0.1, R);
  k3 = 1.0 - smoothstep(0.2, 0.3, R);

  if (k1 == 0.0)
  {
    discard;                                                                    // Discarding fragment point...
  }

  fragment_color = vec4(0.8*vec3(k2, 1.2*k3, k1) + voxel_color.rgb, 0.2 + k1);
}
