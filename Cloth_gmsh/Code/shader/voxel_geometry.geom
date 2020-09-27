/// @file
#version 460 core

#define s 0.005

uniform mat4 V_mat;                                                             // View matrix.
uniform mat4 P_mat;                                                             // Projection matrix.
uniform float size_x;                                                           // Framebuffer size_x.
uniform float size_y;                                                           // Framebuffer size_y.
uniform float AR;                                                               // Framebuffer aspect ratio.

layout (points) in;                                                             // Input points.
layout (triangle_strip, max_vertices = 64) out;                                 // Output points.

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
  vec2 base;
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
    
    P = P_mat*V_mat*center_SSBO[i];                                             // Getting center node (in clip space)...
    Q = P_mat*V_mat*center_SSBO[k];                                             // Getting neighbour node (in clip space)...

    link = normalize(vec2((Q.x/Q.w - P.x/P.w)*AR, (Q.y/Q.w - P.y/P.w)));        // Computing PQ segment (in window space)...
    base = normalize(vec2(-link.y, link.x));                                    // Computing segment orthogonal to PQ (in window space)...

    // COMPUTING BILLBOARD:
    A = s*vec4((-base.x - link.x)/AR, (-base.y - link.y), 0.0, 0.0);            // Computing offset point A (in clip space)...
    B = s*vec4((+base.x - link.x)/AR, (+base.y - link.y), 0.0, 0.0);            // Computing offset point B (in clip space)...
    C = s*vec4((-base.x + link.x)/AR, (-base.y + link.y), 0.0, 0.0);            // Computing offset point C (in clip space)...
    D = s*vec4((+base.x + link.x)/AR, (+base.y + link.y), 0.0, 0.0);            // Computing offset point D (in clip space)...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position =  P + A;                                                       // Adding offset (in clip space)...
    quad = vec2(-1.0, -1.0);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...
    gl_Position =  P + B;                                                       // Adding offset (in clip space)...
    quad = vec2(+1.0, -1.0);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = Q + C;                                                        // Adding offset (in clip space)...
    quad = vec2(-1.0, +1.0);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = Q + D;                                                        // Adding offset (in clip space)...
    quad = vec2(+1.0, +1.0);
    EmitVertex();                                                               // Emitting vertex...

    /*
    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = P + A;                                                        // Adding offset (in clip space)...
    quad = vec2(-1.0, -1.0);
    EmitVertex();                                                               // Emitting vertex...
    */

    EndPrimitive();                                                             // Ending primitive...
  }
}
