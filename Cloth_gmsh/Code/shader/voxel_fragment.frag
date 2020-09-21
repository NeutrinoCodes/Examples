/// @file
#version 460 core

// Voxel colors:
layout(std430, binding = 0) buffer voxel_color
{
  vec4 color_SSBO[];                                                            // Voxel color SSBO.
};

// Voxel centers:
layout(std430, binding = 1) buffer voxel_center
{
  vec4 center_SSBO[];                                                           // Voxel center SSBO.
};

// Voxel nearest neighbours:
layout(std430, binding = 11) buffer voxel_nearest
{
  int nearest_SSBO[];                                                           // Voxel nearest SSBO.
};

// Voxel offsets:
layout(std430, binding = 12) buffer voxel_offset
{
  int offset_SSBO[];                                                            // Voxel offset SSBO.
};

in vec4 color;
in mat4 V_mat;
in mat4 P_mat;

out vec4 fragment_color;                                                        // Fragment color.

void main(void)
{
  uint i = gl_PrimitiveID;
  uint j = 0;
  uint j_min = 0;
  uint j_max = offset_SSBO[i];
  uint k = 0;
  vec4 center; 
  vec4 node;
  vec2 P;                                                                       // 2D fragment coordinates of the voxel.
  float R;                                                                      // Radius of the voxel.
  float k1;                                                                     // Smoothness coefficient.
  float k2;
  float k3;

  /*
  //color = color_SSBO[i];
  center = center_SSBO[i];
  node = P_mat*V_mat*center;

  // COMPUTING STRIDE MINIMUM INDEX:
  if (i == 0)
  {
    j_min = 0;                                                                  // Setting stride minimum (first stride)...
  }
  else
  {
    j_min = offset_SSBO[i - 1];                                                 // Setting stride minimum (all others)...
  }

  for (j = j_min; j < j_max; j++)
  {
    k = nearest_SSBO[j];                                                        // Computing neighbour index...
  }

  P = gl_PointCoord;                                                            // Getting fragment coordinates...
  R = distance(P, vec2(0.5, 0.5));                                              // Computing voxel radius...
  k1 = 1.0 - smoothstep(0.0, 0.5, R);                                           // Computing smoothness coefficient...
  k2 = 1.0 - smoothstep(0.0, 0.1, R);
  k3 = 1.0 - smoothstep(0.2, 0.3, R);

  if (k1 == 0.0)
  {
    discard;                                                                    // Discarding fragment point...
  }
*/

  //fragment_color = vec4(0.8*vec3(k2, 1.2*k3, k1) + color.rgb, 0.2 + k1);
  fragment_color = color;
}
