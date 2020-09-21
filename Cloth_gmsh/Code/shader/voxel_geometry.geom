/// @file
#version 460 core

layout (points) in;                                                             // Input points.
layout (triangle_strip, max_vertices = 26) out;                                         // Output points.

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

in VS_OUT
{
  mat4 V_mat;                                                                   // View matrix.
  mat4 P_mat;                                                                   // Projection matrix.
} gs_in[];

out vec4 color;
out mat4 V_mat;
out mat4 P_mat;

const float size = 40;                                                          // Node graphics size.
const vec2 WIN_SCALE = vec2(800, 600);

void main()
{
  uint i = gl_PrimitiveIDIn;                                                    // Central node index.        
  uint j = 0;                                                                   // Neighbour node index.
  uint j_min = 0;                                                               // Neighbour node minimum index.
  uint j_max = offset_SSBO[i];                                                  // Neighbour node maximum index.
  uint k_2nd = 0;                                                               // 2nd neighbour node index.
  uint k_3rd = 0;                                                               // 3rd neighbour node index.

  mat4 V_mat = gs_in[0].V_mat;                                                  // View matrix.
  mat4 P_mat = gs_in[0].P_mat;                                                  // Projection matrix.

  V_mat = gs_in[0].V_mat;                                                       // Getting view matrix...
  P_mat = gs_in[0].P_mat;                                                       // Getting projection matrix...
  
  // FINDING MINIMUM STRIDE INDEX:
  if (i == 0)
  {
    j_min = 0;                                                                  // Setting stride minimum (first stride)...
  }
  else
  {
    j_min = offset_SSBO[i - 1];                                                 // Setting stride minimum (all others)...
  }

  // BUILDING NEIGHBOUR TRIANGLES:
  for (j = j_min; j < (j_max - 1); j++)
  {
    k_2nd = nearest_SSBO[j];                                                    // Computing neighbour index...
    k_3rd = nearest_SSBO[j + 1];                                                // Computing neighbour index...
    
    color = color_SSBO[i];
    gl_Position = P_mat*V_mat*center_SSBO[i];                                   // Setting 1st triangle vertex...
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];
    gl_Position = P_mat*V_mat*center_SSBO[k_2nd];                               // Setting 2nd triangle vertex...
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];
    gl_Position = P_mat*V_mat*center_SSBO[k_3rd];                               // Setting 2nd triangle vertex...
    EmitVertex();                                                               // Emitting vertex...

    EndPrimitive();                                                             // Ending primitive...
  }

  
}
