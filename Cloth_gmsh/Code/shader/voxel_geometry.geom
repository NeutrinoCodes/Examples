/// @file
#version 460 core

layout (points) in;                                                             // Input points.
layout (points, max_vertices = 26) out;                                         // Output points.

layout(std430, binding = 0) buffer voxel_color
{
  vec4 color_SSBO[];                                                            // Voxel color SSBO.
};

layout(std430, binding = 1) buffer voxel_center
{
  vec4 center_SSBO[];                                                           // Voxel center SSBO.
};

layout(std430, binding = 11) buffer voxel_nearest
{
  int nearest_SSBO[];                                                           // Voxel nearest SSBO.
};

layout(std430, binding = 12) buffer voxel_offset
{
  int offset_SSBO[];                                                            // Voxel offset SSBO.
};

in VS_OUT
{
  mat4 V_mat;                                                                   // View matrix.
  mat4 P_mat;                                                                   // Porojection matrix.
} gs_in[];

out vec4 color;                                                                 // Voxel color (for fragment shader).
out vec4 center;                                                                // Voxel center (for fragment shader).
out vec4 point;                                                                 // Voxel point (for fragment shader).

const float size = 40;

void main()
{
  uint i = gl_PrimitiveIDIn;
  uint j = 0;
  uint j_min = 0;
  uint j_max = offset_SSBO[i];
  vec4 middle;
  uint k = 0;
  mat4 V_mat = gs_in[0].V_mat;
  mat4 P_mat = gs_in[0].P_mat;

  color = color_SSBO[i];
  center = center_SSBO[i];
  point = P_mat*V_mat*center;

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
    
    /*
    out_color = vec4(1.0, 0.0, 0.0, 1.0);
    gl_Position = P_mat*V_mat*center;
    EmitVertex();

    out_color = vec4(1.0, 0.0, 0.0, 1.0);
    gl_Position = P_mat*V_mat*center_SSBO[k];
    EmitVertex();

    middle = 0.5*(center + center_SSBO[k]);
    middle.w = 1.0;
    middle.z += 0.004;

    out_color = vec4(1.0, 0.0, 0.0, 1.0);
    gl_Position = P_mat*V_mat*(middle);
    */
  }

  gl_Position = point;     
  gl_PointSize = (1.0 - gl_Position.z / gl_Position.w) * size;                  // Computing voxel point size...
  EmitVertex();
  EndPrimitive();
}
