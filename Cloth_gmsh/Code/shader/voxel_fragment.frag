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
in float AR_quad;

out vec4 fragment_color;                                                        // Fragment color.

void main(void)
{
  uint i = gl_PrimitiveID;
  uint j = 0;
  uint j_min = 0;
  uint j_max = offset_SSBO[i];
  uint k = 0;
 
  float xP = -0.5*AR_quad + 0.5;
  float xQ = 0.5*AR_quad - 0.5;
  vec2 P = vec2(xP, 0.0);
  vec2 Q = vec2(xQ, 0.0);
  vec2 DP = P - quad;
  vec2 DQ = Q - quad;
  float A;
  float B;
  float f;

  A = length(DP);
  B = length(DQ);
  f = (1.0/A) + (1.0/B) + 1.0*log((DQ.x + B)/(DP.x + A));
  //f = (1.0/A) + (1.0/B);


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

  if (f < 10)
  {
    discard;                                                                    // Discarding fragment point...
  }

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

  //fragment_color = vec4(0.8*vec3(k2, 1.2*k3, k1) + color.rgb, 0.2 + k1);        // Setting fragment color...
  fragment_color = color;
}
