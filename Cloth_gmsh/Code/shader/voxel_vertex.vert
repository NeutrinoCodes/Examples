/// @file
#version 410 core

layout (location = 0) in vec4 voxel_color;                                      // Voxel color.
layout (location = 1) in vec4 voxel_center;                                     // Voxel center.

out VS_OUT
{
  vec4 color;                                                                   // Color.
  vec4 center;                                                                  // Center.
  mat4 V_mat;
  mat4 P_mat;
} vs_out;

uniform mat4 V_mat;                                                             // View matrix.
uniform mat4 P_mat;                                                             // Projection matrix.

/// @function
// Computing rendering point coordinates:
void main(void)
{
  vs_out.color = voxel_color;                    
  vs_out.center = voxel_center;        
  vs_out.V_mat = V_mat;
  vs_out.P_mat = P_mat;
}