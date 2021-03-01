/// @file
#version 460 core

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

layout(std430, binding = 11) buffer voxel_central
{
  int central_SSBO[];                                                           // Voxel central SSBO.
};

layout(std430, binding = 12) buffer voxel_nearest
{
  int nearest_SSBO[];                                                           // Voxel nearest SSBO.
};

layout(std430, binding = 13) buffer voxel_offset
{
  int offset_SSBO[];                                                            // Voxel offset SSBO.
};

layout(std430, binding = 14) buffer voxel_freedom
{
  int freedom_SSBO[];                                                           // Voxel freedom SSBO.
};

layout(std430, binding = 15) buffer voxel_dt
{
  float dt_SSBO[];                                                              // Voxel dt SSBO.
};

float x_over_y(float x, float y)
{
    return (x/y);
}