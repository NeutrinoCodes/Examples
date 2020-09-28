/// @file
#version 460 core

uniform mat4 V_mat;                                                             // View matrix.
uniform mat4 P_mat;                                                             // Projection matrix.
uniform float size_x;                                                           // Framebuffer size_x.
uniform float size_y;                                                           // Framebuffer size_y.
uniform float AR;                                                               // Framebuffer aspect ratio.

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
in vec2 quad;

out vec4 fragment_color;                                                        // Fragment color.

void main(void)
{
  uint i = gl_PrimitiveID;
  uint j = 0;
  uint j_min = 0;
  uint j_max = offset_SSBO[i];
  uint k = 0;
 
  vec2 P = vec2(x_P, 0.0);
  vec2 Q = vec2(x_Q, 0.0);

  float A;
  float B;
  float C;
  float d;
  float T;
  float f;

  A = abs(quad + P);
  B = abs(quad + Q);
  f = (1/A) + (1/B) + (1/C)*abs((1/A + 1/B), ())


  /*
  float k1;                                                                     // Smoothness coefficient.
  float k2;                                                                     // Smoothness coefficient.
  float k3;                                                                     // Smoothness coefficient.
  float R;                                                                      // Blooming radius.

  R = length(quad);                                                             // Setting blooming radius...

  k1 = 1.0 - smoothstep(0.0, 0.5, R);                                           // Computing smoothness coefficient...
  k2 = 1.0 - smoothstep(0.0, 0.1, R);                                           // Computing smoothness coefficient...
  k3 = 1.0 - smoothstep(0.2, 0.3, R);                                           // Computing smoothness coefficient...

  if (k1 == 0.0)
  {
    discard;                                                                    // Discarding fragment point...
  }
  */

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

  fragment_color = vec4(0.8*vec3(k2, 1.2*k3, k1) + color.rgb, 0.2 + k1);        // Setting fragment color...
  //fragment_color = color;
}
