/// @file
#version 460 core

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
out float s;
out float AR_quad;

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

  vec4 a;
  vec4 b;
  vec4 c;
  vec4 d;
  vec4 e;
  vec4 f;

  mat2 M;
  
  vec2 link;
  vec4 P;
  vec4 Q;

  float base;
  float height;

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

    link = normalize(vec2(AR*(Q.x/Q.w - P.x/P.w), (Q.y/Q.w - P.y/P.w)));        // Computing PQ segment (in window space)...

    M[0][0] = link.x; M[0][1] = +link.y;
    M[1][0] = -link.y; M[1][1] = link.x; 

    s = 0.02;

    // COMPUTING BILLBOARD:
    A = s*vec4(-0.5, +0.5, 0.0, 1.0);
    B = s*vec4(-0.5, -0.5, 0.0, 1.0);
    C = s*vec4(+0.5, +0.5, 0.0, 1.0);
    D = s*vec4(+0.5, -0.5, 0.0, 1.0);

    A.xy = M*A.xy;
    B.xy = M*B.xy;
    C.xy = M*C.xy;
    D.xy = M*D.xy;
    
    a = vec4(P_mat*(V_mat*center_SSBO[i] + A));
    b = vec4(P_mat*(V_mat*center_SSBO[i] + B));
    c = vec4(P_mat*(V_mat*center_SSBO[k] + C));
    d = vec4(P_mat*(V_mat*center_SSBO[k] + D));
    e = vec4(P_mat*(V_mat*center_SSBO[i] + 0.5*(A + B)));
    f = vec4(P_mat*(V_mat*center_SSBO[k] + 0.5*(C + D)));

    base = length(vec2(AR*(b.x/b.w - a.x/a.w), (b.y/b.w - a.y/a.w)));
    height = length(vec2(AR*(f.x/f.w - e.x/e.w), (f.y/f.w - e.y/e.w)));

    AR_quad = height/base;

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = P_mat*(V_mat*center_SSBO[i] + A);                             // Adding offset...
    quad = vec2(-0.5*AR_quad, +0.5);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...
    gl_Position = P_mat*(V_mat*center_SSBO[i] + B);                             // Adding offset...
    quad = vec2(-0.5*AR_quad, -0.5);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = P_mat*(V_mat*center_SSBO[k] + C);                             // Adding offset...
    quad = vec2(+0.5*AR_quad, +0.5);
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = P_mat*(V_mat*center_SSBO[k] + D);                             // Adding offset...
    quad = vec2(+0.5*AR_quad, -0.5);
    EmitVertex();                                                               // Emitting vertex...

    EndPrimitive();                                                             // Ending primitive...
  }
}
