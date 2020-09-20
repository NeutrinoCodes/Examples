/// @file
#version 410 core

uniform mat4 V_mat;                                                             // View matrix.
uniform mat4 P_mat;                                                             // Projection matrix.

out VS_OUT
{
  mat4 V_mat;                                                                   // View matrix.
  mat4 P_mat;                                                                   // Projection matrix.
} vs_out;

/// @function
// Forwarding view and projection matrices:
void main(void)
{        
  vs_out.V_mat = V_mat;
  vs_out.P_mat = P_mat;
}