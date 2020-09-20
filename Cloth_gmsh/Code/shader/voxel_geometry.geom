/// @file
#version 460 core

layout (points) in;                                                             // Input points.
layout (points, max_vertices = 26) out;                                         // Output points.

// Voxel colors:
layout(std430, binding = 0) buffer voxel_color
{
  vec4 color_SSBO[];                                                            // Voxel color SSBO.
};

layout(std430, binding = 1) buffer voxel_center
{
  vec4 center_SSBO[];                                                           // Voxel center SSBO.
};

in VS_OUT
{
  mat4 V_mat;                                                                   // View matrix.
  mat4 P_mat;                                                                   // Projection matrix.
} gs_in[];

out vec4 color;
out mat4 V_mat;
out mat4 P_mat;

const float size = 40;                                                          // Node graphics size.

void main()
{
  uint i = gl_PrimitiveIDIn;                                                    // Getting primitive index...        

  V_mat = gs_in[0].V_mat;
  P_mat = gs_in[0].P_mat;
  
  color = color_SSBO[i];
  gl_Position = P_mat*V_mat*center_SSBO[i];                                     // Setting center position...
  gl_PointSize = (1.0 - gl_Position.z/gl_Position.w)*size;                      // Computing node size in projective space...
  EmitVertex();                                                                 // Emitting vertex...
  EndPrimitive();                                                               // Ending primitive...
}
