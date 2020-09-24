/// @file
#version 460 core

#define s 0.01

uniform mat4 V_mat;                                                             // View matrix.
uniform mat4 P_mat;                                                             // Projection matrix.
uniform float size_x;                                                           // Framebuffer size_x.
uniform float size_y;                                                           // Framebuffer size_y.
uniform float AR;                                                               // Framebuffer aspect ratio.

layout (points) in;                                                             // Input points.
layout (line_strip, max_vertices = 26) out;                                 // Output points.

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

out vec4 color;
out vec2 quad;

void main()
{
  uint i = gl_PrimitiveIDIn;                                                    // Central node index.        
  uint j = 0;                                                                   // Offset index.
  uint j_min = 0;                                                               // Neighbour node minimum index.
  uint j_max = offset_SSBO[i];                                                  // Neighbour node maximum index.
  uint k = 0;                                                                   // Neighbour node index.

  vec4 A;
  vec4 B;
  vec4 C;
  vec4 D;

  vec4 P;
  vec4 Q;
  vec2 link;
  mat2 M;

  // FINDING MINIMUM STRIDE INDEX:
  if (i == 0)
  {
    j_min = 0;                                                                  // Setting stride minimum (first stride)...
  }
  else
  {
    j_min = offset_SSBO[i - 1];                                                 // Setting stride minimum (all others)...
  }

  // BUILDING LINE FROM CENTER TO NEIGHBOUR:
  for (j = j_min; j < j_max; j++)
  {
    k = nearest_SSBO[j];                                                        // Computing neighbour index...
    
    P = P_mat*V_mat*center_SSBO[i];
    Q = P_mat*V_mat*center_SSBO[k];
    vec2 H;

    float alpha = 3.14/4.0;

    link = normalize(Q.xy/Q.w - P.xy/P.w);
    //M = mat2(link.x, -link.y, +link.y, link.x);
    M = mat2(link.y, -link.x, +link.x, link.y);

    A = vec4(-link.x, 0.0, 0.0, 0.0);
    B = vec4(+link.x, 0.0, 0.0, 0.0);

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = P;        // Setting voxel position...
    quad = vec2(-1.0, -1.0);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...
    H = M*A.xy;
    gl_Position = Q + s*vec4(H.x, H.y, 0.0, 0.0);        // Setting voxel position...
    quad = vec2(+1.0, -1.0);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    H = M*B.xy;
    gl_Position = Q + s*vec4(H.x, H.y, 0.0, 0.0); ;        // Setting voxel position...
    quad = vec2(-1.0, +1.0);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = P;        // Setting voxel position...
    quad = vec2(+1.0, +1.0);
    EmitVertex();                                                               // Emitting vertex...

    EndPrimitive();                                                             // Ending primitive...

    /*
    color = color_SSBO[i];
    gl_Position = P_mat*V_mat*center_SSBO[i];                                   // Setting central vertex...
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];
    gl_Position = P_mat*V_mat*center_SSBO[k];                                   // Setting neighbour vertex...
    EmitVertex();                                                               // Emitting vertex...

    EndPrimitive();                                                             // Ending primitive...
    */
  }

  /*
  color = color_SSBO[i];                                                        // Setting voxel color...  
  gl_Position = P_mat*V_mat*(center_SSBO[i]) + A;                               // Setting voxel position...
  quad = vec2(-1.0, -1.0);
  EmitVertex();                                                                 // Emitting vertex...

  color = color_SSBO[i];                                                        // Setting voxel color...
  gl_Position = P_mat*V_mat*(center_SSBO[i]) + B;                               // Setting voxel position...
  quad = vec2(+1.0, -1.0);
  EmitVertex();                                                                 // Emitting vertex...

  color = color_SSBO[i];                                                        // Setting voxel color...
  gl_Position = P_mat*V_mat*(center_SSBO[i]) + C;                               // Setting voxel position...
  quad = vec2(-1.0, +1.0);
  EmitVertex();                                                                 // Emitting vertex...

  color = color_SSBO[i];                                                        // Setting voxel color...
  gl_Position = P_mat*V_mat*(center_SSBO[i]) + D;                               // Setting voxel position...
  quad = vec2(+1.0, +1.0);
  EmitVertex();                                                                 // Emitting vertex...

  EndPrimitive();                                                               // Ending primitive...
  */
}
