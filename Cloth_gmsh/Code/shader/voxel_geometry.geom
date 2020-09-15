/// @file
#version 460 core

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////// VOXEL: 3D binary hypercube //////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//
//       (-1.0, +1.0, -1.0)    C--------G  (+1.0, +1.0, -1.0)
//                            /|       /|
//       (-1.0, +1.0, +1.0)  D--------H |  (+1.0, +1.0, +1.0)
//       (-1.0, -1.0, -1.0)  | A------|-E  (+1.0, -1.0, -1.0)
//                           |/       |/
//       (-1.0, -1.0, +1.0)  B--------F    (+1.0, -1.0, +1.0)
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
//
//                               y (points up)
//                               |
//                               o -- x (points right)
//                              /
//                             z (points out of the screen)
//
//                               UP
//                               |  / BACK
//                               | /
//                     LEFT -----+----- RIGHT
//                              /|
//                       FRONT / |
//                              DOWN
//
//////////////////////////////////////////////////////////////////////////////////
#define A vec3(-1.0, -1.0, -1.0)                                                // Vertex "A".
#define B vec3(-1.0, -1.0, +1.0)                                                // Vertex "B".
#define C vec3(-1.0, +1.0, -1.0)                                                // Vertex "C".
#define D vec3(-1.0, +1.0, +1.0)                                                // Vertex "D".
#define E vec3(+1.0, -1.0, -1.0)                                                // Vertex "E".
#define F vec3(+1.0, -1.0, +1.0)                                                // Vertex "F".
#define G vec3(+1.0, +1.0, -1.0)                                                // Vertex "G".
#define H vec3(+1.0, +1.0, +1.0)                                                // Vertex "H".

#define nL vec3(-1.0, +0.0, +0.0)                                               // Normal "LEFT".
#define nR vec3(+1.0, +0.0, +0.0)                                               // Normal "RIGHT".
#define nD vec3(+0.0, -1.0, +0.0)                                               // Normal "DOWN".
#define nU vec3(+0.0, +1.0, +0.0)                                               // Normal "UP".
#define nB vec3(+0.0, +0.0, -1.0)                                               // Normal "BACK".
#define nF vec3(+0.0, +0.0, +1.0)                                               // Normal "FRONT".

#define s 0.008                                                                 // Voxel side.
#define l vec3(0.0, -1.0, 0.0)                                                  // Light direction.

layout (points) in;                                                             // Input points.
layout (triangle_strip, max_vertices = 26) out;                                 // Output points.

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
  mat4 P_mat;                                                                   // Projection matrix.
} gs_in[];

out vec4 out_color;                                                             // Voxel color (for fragment shader).

void main()
{
  uint i = gl_PrimitiveIDIn;
  uint j = 0;
  uint j_min = 0;
  uint j_max = offset_SSBO[i];
  vec4 center = center_SSBO[i];
  vec4 color = color_SSBO[i];
  vec4 middle;
  uint k = 0;
  mat4 V_mat = gs_in[0].V_mat;
  mat4 P_mat = gs_in[0].P_mat;

  vec3 light;                                                                   // Light direction.

  vec3 normal_L;                                                                // LEFT:  face "ABDC" normal.
  vec3 normal_R;                                                                // RIGHT: face "EFGH" normal.
  vec3 normal_D;                                                                // DOWN:  face "ABFE" normal.
  vec3 normal_U;                                                                // UP:    face "CDHG" normal.
  vec3 normal_B;                                                                // BACK:  face "AEGC" normal.
  vec3 normal_F;                                                                // FRONT: face "BFHD" normal.

  float diffusion_L;                                                            // LEFT:  face "ABDC" diffusion coefficient.
  float diffusion_R;                                                            // RIGHT: face "EFGH" diffusion coefficient.
  float diffusion_D;                                                            // DOWN:  face "ABFE" diffusion coefficient.
  float diffusion_U;                                                            // UP:    face "CDHG" diffusion coefficient.
  float diffusion_B;                                                            // BACK:  face "AEGC" diffusion coefficient.
  float diffusion_F;                                                            // FRONT: face "BFHD" diffusion coefficient.

  vec4 vertex_A;
  vec4 vertex_B;
  vec4 vertex_C;
  vec4 vertex_D;
  vec4 vertex_E;
  vec4 vertex_F;
  vec4 vertex_G;
  vec4 vertex_H;

  vec4 color_L;
  vec4 color_R;
  vec4 color_D;
  vec4 color_U;
  vec4 color_B;
  vec4 color_F;

  light = -normalize(l);                                                        // Normalizing and inverting light direction...

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////// VOXEL'S FACE BARICENTRIC NORMALS /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  normal_L = vec3(P_mat*V_mat*(center + vec4(nL, +1.0)));                       // LEFT:  computing face "ABDC" normal.
  normal_R = vec3(P_mat*V_mat*(center + vec4(nR, +1.0)));                       // RIGHT: fcomputing face "EFHG" normal.
  normal_D = vec3(P_mat*V_mat*(center + vec4(nD, +1.0)));                       // DOWN:  computing face "ABFE" normal.
  normal_U = vec3(P_mat*V_mat*(center + vec4(nU, +1.0)));                       // UP:    computing face "CDHG" normal.
  normal_B = vec3(P_mat*V_mat*(center + vec4(nB, +1.0)));                       // BACK:  computing face "AEGC" normal.
  normal_F = vec3(P_mat*V_mat*(center + vec4(nF, +1.0)));                       // FRONT: computing face "BFHD" normal.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////// VOXEL'S FACE DIFFUSION COEFFICIENTS //////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  diffusion_L = clamp(dot(light, normal_L), 0.2, 1.0);                          // LEFT:  computing face "ABDC" diffusion coefficient.
  diffusion_R = clamp(dot(light, normal_R), 0.2, 1.0);                          // RIGHT: computing face "EFGH" diffusion coefficient.
  diffusion_D = clamp(dot(light, normal_D), 0.2, 1.0);                          // DOWN:  computing face "ABFE" diffusion coefficient.
  diffusion_U = clamp(dot(light, normal_U), 0.2, 1.0);                          // UP:    computing face "CDHG" diffusion coefficient.
  diffusion_B = clamp(dot(light, normal_B), 0.2, 1.0);                          // BACK:  computing face "AEGC" diffusion coefficient.
  diffusion_F = clamp(dot(light, normal_F), 0.2, 1.0);                          // FRONT: computing face "BFHD" diffusion coefficient.

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// VOXEL'S VERTEX BARICENTRIC COORDINATES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  vertex_A = P_mat*V_mat*(center + vec4(s*A, 0.0));                             // Computing vertex "A".
  vertex_B = P_mat*V_mat*(center + vec4(s*B, 0.0));                             // Computing vertex "B".
  vertex_C = P_mat*V_mat*(center + vec4(s*C, 0.0));                             // Computing vertex "C".
  vertex_D = P_mat*V_mat*(center + vec4(s*D, 0.0));                             // Computing vertex "D".
  vertex_E = P_mat*V_mat*(center + vec4(s*E, 0.0));                             // Computing vertex "E".
  vertex_F = P_mat*V_mat*(center + vec4(s*F, 0.0));                             // Computing vertex "F".
  vertex_G = P_mat*V_mat*(center + vec4(s*G, 0.0));                             // Computing vertex "G".
  vertex_H = P_mat*V_mat*(center + vec4(s*H, 0.0));                             // Computing vertex "H".

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////// VOXEL'S FACE COLORS //////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  color_L = vec4(diffusion_L*vec3(color), 1.0);                                 // LEFT:  computing face "ABDC" color.
  color_R = vec4(diffusion_R*vec3(color), 1.0);                                 // RIGHT: computing face "EFHG" color.
  color_D = vec4(diffusion_D*vec3(color), 1.0);                                 // DOWN:  computing face "ABFE" color.
  color_U = vec4(diffusion_U*vec3(color), 1.0);                                 // UP:    computing face "CDHG" color.
  color_B = vec4(diffusion_B*vec3(color), 1.0);                                 // BACK:  computing face "AEGC" color.
  color_F = vec4(diffusion_F*vec3(color), 1.0);                                 // FRONT: computing face "BFHD" color.

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
    k = nearest_SSBO[j_min];                                                        // Computing neighbour index...
    
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
    EmitVertex();

    EndPrimitive();
  }

  /////////////////////////// LEFT SIDE: ABC + (BC)D /////////////////////////////
  out_color = color_L;                                                          // Setting voxel color...
  gl_Position = vertex_A;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "A" vertex.

  out_color = color_L;                                                          // Setting voxel color...
  gl_Position = vertex_B;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "B" vertex.

  out_color = color_L;                                                          // Setting voxel color...
  gl_Position = vertex_C;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "C" vertex.

  out_color = color_L;                                                          // Setting voxel color...
  gl_Position = vertex_D;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "D" vertex.

  EndPrimitive();                                                               // Ending primitive...

  //////////////////////////// RIGHT SIDE: EGF + (GF)H ///////////////////////////
  out_color = color_R;                                                          // Setting voxel color...
  gl_Position = vertex_E;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "E" vertex.

  out_color = color_R;                                                          // Setting voxel color...
  gl_Position = vertex_G;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "G" vertex.

  out_color = color_R;                                                          // Setting voxel color...
  gl_Position = vertex_F;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "F" vertex.

  out_color = color_R;                                                          // Setting voxel color...
  gl_Position = vertex_H;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "H" vertex.

  EndPrimitive();                                                               // Ending primitive...

  ////////////////////////////// BOTTOM SIDE: AEB + (EB)F ////////////////////////
  out_color = color_B;                                                          // Setting voxel color...
  gl_Position = vertex_A;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "A" vertex.

  out_color = color_B;                                                          // Setting voxel color...
  gl_Position = vertex_E;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "E" vertex.

  out_color = color_B;                                                          // Setting voxel color...
  gl_Position = vertex_B;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "B" vertex.

  out_color = color_B;                                                          // Setting voxel color...
  gl_Position = vertex_F;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "F" vertex.

  EndPrimitive();                                                               // Ending primitive...

  ///////////////////////////// UP SIDE: CGD + (GD)H /////////////////////////////
  out_color = color_U;                                                          // Setting voxel color...
  gl_Position = vertex_C;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "C" vertex.

  out_color = color_U;                                                          // Setting voxel color...
  gl_Position = vertex_G;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "G" vertex.

  out_color = color_U;                                                          // Setting voxel color...
  gl_Position = vertex_D;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "D" vertex.

  out_color = color_U;                                                          // Setting voxel color...
  gl_Position = vertex_H;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "H" vertex.

  EndPrimitive();                                                               // Ending primitive...

  //////////////////////////// BACK SIDE: ACE + (CE)G ////////////////////////////
  out_color = color_B;                                                          // Setting voxel color...
  gl_Position = vertex_A;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "A" vertex.

  out_color = color_B;                                                          // Setting voxel color...
  gl_Position = vertex_C;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "C" vertex.

  out_color = color_B;                                                          // Setting voxel color...
  gl_Position = vertex_E;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "E" vertex.

  out_color = color_B;                                                          // Setting voxel color...
  gl_Position = vertex_G;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "G" vertex.

  EndPrimitive();                                                               // Ending primitive...

  ///////////////////////////// FRONT SIDE: BFD + (FD)H //////////////////////////
  out_color = color_F;                                                          // Setting voxel color...
  gl_Position = vertex_B;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "B" vertex.

  out_color = color_F;                                                          // Setting voxel color...
  gl_Position = vertex_F;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "F" vertex.

  out_color = color_F;                                                          // Setting voxel color...
  gl_Position = vertex_D;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "D" vertex.

  out_color = color_F;                                                          // Setting voxel color...
  gl_Position = vertex_H;                                                       // Setting voxel position...
  EmitVertex();                                                                 // "H" vertex.

  EndPrimitive();                                                               // Ending primitive...
}
