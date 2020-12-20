/// @file
#version 460 core

float x_over_y(float x, float y);

uniform mat4 V_mat;                                                             // View matrix.
uniform mat4 P_mat;                                                             // Projection matrix.
uniform float size_x;                                                           // Framebuffer size_x.
uniform float size_y;                                                           // Framebuffer size_y.
uniform float AR;                                                               // Framebuffer aspect ratio.

layout (points) in;                                                             // Input points.
layout (triangle_strip, max_vertices = 64) out;                                 // Output points.

layout(std430, binding = 0) buffer voxel_color
{
  vec4 color_SSBO[];                                                            // Voxel color SSBO.
};

layout(std430, binding = 1) buffer voxel_position
{
  vec4 position_SSBO[];                                                         // Voxel position SSBO.
};

layout(std430, binding = 2) buffer voxel_velocity
{
  vec4 velocity_SSBO[];                                                         // Voxel velocity SSBO.
};

layout(std430, binding = 3) buffer voxel_acceleration
{
  vec4 acceleration_SSBO[];                                                     // Voxel acceleration SSBO.
};

layout(std430, binding = 4) buffer voxel_position_int
{
  vec4 position_int_SSBO[];                                                     // Voxel intermediate position SSBO.
};

layout(std430, binding = 5) buffer voxel_velocity_int
{
  vec4 velocity_int_SSBO[];                                                     // Voxel intermediate velocity SSBO.
};

layout(std430, binding = 6) buffer voxel_gravity
{
  vec4 gravity_SSBO[];                                                          // Voxel gravity SSBO.
};

layout(std430, binding = 7) buffer voxel_stiffness
{
  float stiffness_SSBO[];                                                       // Voxel stiffness SSBO.
};

layout(std430, binding = 8) buffer voxel_resting
{
  float resting_SSBO[];                                                         // Voxel resting SSBO.
};

layout(std430, binding = 9) buffer voxel_friction
{
  float friction_SSBO[];                                                        // Voxel friction SSBO.
};

layout(std430, binding = 10) buffer voxel_mass
{
  float mass_SSBO[];                                                            // Voxel mass SSBO.
};

layout(std430, binding = 11) buffer voxel_nearest
{
  int nearest_SSBO[];                                                           // Voxel nearest SSBO.
};

layout(std430, binding = 12) buffer voxel_offset
{
  int offset_SSBO[];                                                            // Voxel offset SSBO.
};

layout(std430, binding = 13) buffer voxel_freedom
{
  int freedom_SSBO[];                                                           // Voxel freedom SSBO.
};

layout(std430, binding = 14) buffer voxel_dt
{
  float dt_SSBO[];                                                              // Voxel dt SSBO.
};

out vec4 color;                                                                 // Fragment color.
out vec2 quad;                                                                  // Billboard quad UV coordinates.
out float AR_quad;                                                              // Billboard quad aspect ratio.

void main()
{
  uint i = gl_PrimitiveIDIn;                                                    // Central node index.        
  uint j = 0;                                                                   // Offset index.
  uint j_min = 0;                                                               // Neighbour node minimum index.
  uint j_max = offset_SSBO[i];                                                  // Neighbour node maximum index.
  uint k = 0;                                                                   // Neighbour node index.

  vec4 A;                                                                       // Billboard vertex "a" (in clip space).
  vec4 B;                                                                       // Billboard vertex "b" (in clip space).
  vec4 C;                                                                       // Billboard vertex "c" (in clip space).
  vec4 D;                                                                       // Billboard vertex "d" (in clip space).

  vec4 a;                                                                       // Billboard boundary "a" (in clip space).
  vec4 b;                                                                       // Billboard boundary "b" (in clip space).
  vec4 c;                                                                       // Billboard boundary "c" (in clip space).
  vec4 d;                                                                       // Billboard boundary "d" (in clip space).
  vec4 e;                                                                       // Billboard boundary "ab" midpoint (in clip space).
  vec4 f;                                                                       // Billboard boundary "cd" midpoint (in clip space).

  vec4 P;                                                                       // Center node (in clip space).
  vec4 Q;                                                                       // Neightbour node (in clip space).
  vec2 link;                                                                    // PQ segment (in window space).
  mat2 M;                                                                       // Billboard rotation matrix (in window space).

  float s;                                                                      // Billboard thickness (in clip space).
  float base;                                                                   // Billboard base (in window space).
  float height;                                                                 // Billboard height (in window space).

  s = 0.02;                                                                     // Setting billboard thickness (in clip space)...

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
    
    // COMPUTING BILLBOARD ROTATION:
    P = P_mat*V_mat*position_SSBO[i];                                           // Getting center node (in clip space)...
    Q = P_mat*V_mat*position_SSBO[k];                                           // Getting neighbour node (in clip space)...
    link = normalize(vec2(AR*(Q.x/Q.w - P.x/P.w), (Q.y/Q.w - P.y/P.w)));        // Computing normalized PQ segment (in window space)...
    M[0][0] = +link.x; M[0][1] = +link.y;                                       // Computing rotation matrix (in window space)...
    M[1][0] = -link.y; M[1][1] = +link.x;                                       // Computing rotation matrix (in window space)...                                                                  
    A = s*vec4(-0.5, +0.5, 0.0, 1.0);                                           // Setting billboard vertex "a" (in clip space)...
    B = s*vec4(-0.5, -0.5, 0.0, 1.0);                                           // Setting billboard vertex "b" (in clip space)...
    C = s*vec4(+0.5, +0.5, 0.0, 1.0);                                           // Setting billboard vertex "c" (in clip space)...
    D = s*vec4(+0.5, -0.5, 0.0, 1.0);                                           // Setting billboard vertex "d" (in clip space)...
    A.xy = M*A.xy;                                                              // Rotating billboard vertex according to PQ segment (in window space)...                                         
    B.xy = M*B.xy;                                                              // Rotating billboard vertex according to PQ segment (in window space)...
    C.xy = M*C.xy;                                                              // Rotating billboard vertex according to PQ segment (in window space)...
    D.xy = M*D.xy;                                                              // Rotating billboard vertex according to PQ segment (in window space)...
    
    // COMPUTING BILLBOARD ASPECT RATIO:
    a = vec4(P_mat*(V_mat*position_SSBO[i] + A));                               // Computing billboard boundary "a" (in clip space)...
    b = vec4(P_mat*(V_mat*position_SSBO[i] + B));                               // Computing billboard boundary "b" (in clip space)...
    c = vec4(P_mat*(V_mat*position_SSBO[k] + C));                               // Computing billboard boundary "c" (in clip space)...
    d = vec4(P_mat*(V_mat*position_SSBO[k] + D));                               // Computing billboard boundary "d" (in clip space)...
    e = vec4(P_mat*(V_mat*position_SSBO[i] + 0.5*(A + B)));                     // Computing billboard "ab" midpoint (in clip space)...
    f = vec4(P_mat*(V_mat*position_SSBO[k] + 0.5*(C + D)));                     // Computing billboard "cd" midpoint (in clip space)...
    height = length(vec2(AR*(b.x/b.w - a.x/a.w), (b.y/b.w - a.y/a.w)));         // Computing billboard height (in window space)...
    base = length(vec2(AR*(f.x/f.w - e.x/e.w), (f.y/f.w - e.y/e.w)));           // Computing billboard base (in window space)...
    //AR_quad = base/height;                                                      // Computing bollboard aspect ratio (in window space)...
    AR_quad = x_over_y(base, height);

    // GENERATING BILLBOARD VERTICES:
    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = a;                                                            // Setting billboard vertex "a"...
    quad = vec2(-0.5*AR_quad, +0.5);                                            // Setting quad vertex (in UV space)...
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...
    gl_Position = b;                                                            // Setting billboard vertex "b"...
    quad = vec2(-0.5*AR_quad, -0.5);                                            // Setting quad vertex (in UV space)...
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = c;                                                            // Setting billboard vertex "c"...
    quad = vec2(+0.5*AR_quad, +0.5);                                            // Setting quad vertex (in UV space)...
    EmitVertex();                                                               // Emitting vertex...

    color = color_SSBO[i];                                                      // Setting voxel color...  
    gl_Position = d;                                                            // Setting billboard vertex "d"...
    quad = vec2(+0.5*AR_quad, -0.5);                                            // Setting quad vertex (in UV space)...
    EmitVertex();                                                               // Emitting vertex...

    EndPrimitive();                                                             // Ending primitive...
  }
}
