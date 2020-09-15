/// @file

#version 460 core

//////////////////////////////////////////////////////////////////////////////////
////////////////////////////// VOXEL: triangulation scheme ///////////////////////
//////////////////////////////////////////////////////////////////////////////////
//
//                             C--------G
//                            /|       /|
//                           D--------H |
//                           | A------|-E
//                           |/       |/
//                           B--------F
//
//  Triangle strip sequence:
//
//             ABC +
//                 | LEFT SIDE
//           (BC)D +
//                 
//             EGF +
//                 | RIGHT SIDE
//           (GF)H +
//
//             AEB +
//                 | BOTTOM SIDE
//           (EB)F +
//
//             CGD +
//                 | UP SIDE
//           (GD)H +
//
//             ACE +
//                 | BACK SIDE
//           (CE)G +
//
//             BFD +
//                 | FRONT SIDE
//           (FD)H +
//////////////////////////////////////////////////////////////////////////////////

layout (points) in;                                                             // Input points.
layout (triangle_strip, max_vertices = 26) out;                                 // Output points.

layout(std430, binding = 1) buffer voxel_center
{
  vec4 center_SSBO[];
};

layout(std430, binding = 11) buffer voxel_nearest
{
  int nearest_SSBO[];
};

layout(std430, binding = 12) buffer voxel_offset
{
  int offset_SSBO[];
};

in VS_OUT
{
  vec4 vertex_A;                                                                // Vertex "A".
  vec4 vertex_B;                                                                // Vertex "B".
  vec4 vertex_C;                                                                // Vertex "C".
  vec4 vertex_D;                                                                // Vertex "D".
  vec4 vertex_E;                                                                // Vertex "E".
  vec4 vertex_F;                                                                // Vertex "F".
  vec4 vertex_G;                                                                // Vertex "G".
  vec4 vertex_H;                                                                // Vertex "H".
  vec4 color_L;                                                                 // LEFT:  face "ABDC" color.
  vec4 color_R;                                                                 // RIGHT: face "EFHG" color.
  vec4 color_D;                                                                 // DOWN:  face "ABFE" color.
  vec4 color_U;                                                                 // UP:    face "CDHG" color.
  vec4 color_B;                                                                 // BACK:  face "AEGC" color.
  vec4 color_F;                                                                 // FRONT: face "BFHD" color.
  mat4 V_mat;
  mat4 P_mat;
} gs_in[];

out vec4 voxel_color;                                                           // Voxel color (for fragment shader).

void main()
{
  uint i = gl_PrimitiveIDIn;
  uint j = 0;
  uint j_min = 0;
  uint j_max = offset_SSBO[i];
  vec4 center = center_SSBO[i];
  uint k = 0;
  mat4 V_mat = gs_in[0].V_mat;
  mat4 P_mat = gs_in[0].P_mat;

  // COMPUTING STRIDE MINIMUM INDEX:
  if (i == 0)
  {
    j_min = 0;                                                                  // Setting stride minimum (first stride)...
  }
  else
  {
    j_min = offset_SSBO[i - 1];                                                 // Setting stride minimum (all others)...
  }

  voxel_color = vec4(1.0f, 0.0f, 0.0f, 1.0f);
  gl_Position = P_mat*V_mat*center;

  for (j = j_min; j < j_max; j++)
  {
    k = nearest_SSBO[j];                                                        // Computing neighbour index...
    gl_Position = P_mat*V_mat*(center_SSBO[k]);
    EmitVertex();
  }

  EndPrimitive();

  /////////////////////////// LEFT SIDE: ABC + (BC)D /////////////////////////////
  voxel_color = gs_in[0].color_L;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_A;                                              // Setting voxel position...
  EmitVertex();                                                                 // "A" vertex.

  voxel_color = gs_in[0].color_L;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_B;                                              // Setting voxel position...
  EmitVertex();                                                                 // "B" vertex.

  voxel_color = gs_in[0].color_L;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_C;                                              // Setting voxel position...
  EmitVertex();                                                                 // "C" vertex.

  voxel_color = gs_in[0].color_L;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_D;                                              // Setting voxel position...
  EmitVertex();                                                                 // "D" vertex.

  EndPrimitive();                                                               // Ending primitive...

  //////////////////////////// RIGHT SIDE: EGF + (GF)H ///////////////////////////
  voxel_color = gs_in[0].color_R;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_E;                                              // Setting voxel position...
  EmitVertex();                                                                 // "E" vertex.

  voxel_color = gs_in[0].color_R;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_G;                                              // Setting voxel position...
  EmitVertex();                                                                 // "G" vertex.

  voxel_color = gs_in[0].color_R;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_F;                                              // Setting voxel position...
  EmitVertex();                                                                 // "F" vertex.

  voxel_color = gs_in[0].color_R;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_H;                                              // Setting voxel position...
  EmitVertex();                                                                 // "H" vertex.

  EndPrimitive();                                                               // Ending primitive...

  ////////////////////////////// BOTTOM SIDE: AEB + (EB)F ////////////////////////
  voxel_color = gs_in[0].color_B;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_A;                                              // Setting voxel position...
  EmitVertex();                                                                 // "A" vertex.

  voxel_color = gs_in[0].color_B;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_E;                                              // Setting voxel position...
  EmitVertex();                                                                 // "E" vertex.

  voxel_color = gs_in[0].color_B;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_B;                                              // Setting voxel position...
  EmitVertex();                                                                 // "B" vertex.

  voxel_color = gs_in[0].color_B;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_F;                                              // Setting voxel position...
  EmitVertex();                                                                 // "F" vertex.

  EndPrimitive();                                                               // Ending primitive...

  ///////////////////////////// UP SIDE: CGD + (GD)H /////////////////////////////
  voxel_color = gs_in[0].color_U;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_C;                                              // Setting voxel position...
  EmitVertex();                                                                 // "C" vertex.

  voxel_color = gs_in[0].color_U;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_G;                                              // Setting voxel position...
  EmitVertex();                                                                 // "G" vertex.

  voxel_color = gs_in[0].color_U;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_D;                                              // Setting voxel position...
  EmitVertex();                                                                 // "D" vertex.

  voxel_color = gs_in[0].color_U;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_H;                                              // Setting voxel position...
  EmitVertex();                                                                 // "H" vertex.

  EndPrimitive();                                                               // Ending primitive...

  //////////////////////////// BACK SIDE: ACE + (CE)G ////////////////////////////
  voxel_color = gs_in[0].color_B;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_A;                                              // Setting voxel position...
  EmitVertex();                                                                 // "A" vertex.

  voxel_color = gs_in[0].color_B;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_C;                                              // Setting voxel position...
  EmitVertex();                                                                 // "C" vertex.

  voxel_color = gs_in[0].color_B;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_E;                                              // Setting voxel position...
  EmitVertex();                                                                 // "E" vertex.

  voxel_color = gs_in[0].color_B;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_G;                                              // Setting voxel position...
  EmitVertex();                                                                 // "G" vertex.

  EndPrimitive();                                                               // Ending primitive...

  ///////////////////////////// FRONT SIDE: BFD + (FD)H //////////////////////////
  voxel_color = gs_in[0].color_F;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_B;                                              // Setting voxel position...
  EmitVertex();                                                                 // "B" vertex.

  voxel_color = gs_in[0].color_F;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_F;                                              // Setting voxel position...
  EmitVertex();                                                                 // "F" vertex.

  voxel_color = gs_in[0].color_F;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_D;                                              // Setting voxel position...
  EmitVertex();                                                                 // "D" vertex.

  voxel_color = gs_in[0].color_F;                                               // Setting voxel color...
  gl_Position = gs_in[0].vertex_H;                                              // Setting voxel position...
  EmitVertex();                                                                 // "H" vertex.

  EndPrimitive();                                                               // Ending primitive...
}
