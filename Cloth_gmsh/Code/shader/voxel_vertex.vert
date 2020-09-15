/// @file
#version 460 core

out VS_OUT
{
  mat4 V_mat;                                                                   // View matrix.
  mat4 P_mat;                                                                   // Projection matrix.
} vs_out;

uniform mat4 V_mat;                                                             // View matrix.
uniform mat4 P_mat;                                                             // Projection matrix.

/// @function
void main(void)
{
  vs_out.V_mat = V_mat;                                                         // Forwarding view matrix to geometry shader...
  vs_out.P_mat = P_mat;                                                         // Forwarding projection matrix to geometry shader...
}
