/// @file
#include "utilities.cl"

__kernel void thekernel(__global point*     voxel_point,
                        __global color*     voxel_color,
                        __global float4*    position_int,
                        __global float4*    velocity,
                        __global float4*    velocity_int,
                        __global float4*    acceleration,
                        __global float4*    acceleration_int,
                        __global float4*    gravity,
                        __global float4*    stiffness,
                        __global float4*    resting,
                        __global float4*    friction,
                        __global float4*    mass,
                        __global long*      index_friend_1,                     // Indexes of "#1 friend" particles.
                        __global long*      index_friend_2,                     // Indexes of "#2 friend" particles.
                        __global long*      index_friend_3,                     // Indexes of "#3 friend" particles.
                        __global long*      index_friend_4,                     // Indexes of "#4 friend" particles.
                        __global float4*    freedom,
                        __global float*     DT)
{

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// GLOBAL INDEX /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned long gid = get_global_id(0);                                         // Setting global index "gid"...

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      P;                                                                // Current particle position.
  float4      col;                                                              // Current particle color.

  P.x = voxel_point[gid].x;                                                    // Getting voxel "x" point coordinate...
  P.y = voxel_point[gid].y;                                                    // Getting voxel "y" point coordinate...
  P.z = voxel_point[gid].z;                                                    // Getting voxel "z" point coordinate...
  P.w = voxel_point[gid].w;                                                    // Getting voxel "w" point coordinate...

  col.x = voxel_color[gid].r;                                                   // Getting voxel "r" color coordinate...
  col.y = voxel_color[gid].g;                                                   // Getting voxel "g" color coordinate...
  col.z = voxel_color[gid].b;                                                   // Getting voxel "b" color coordinate...
  col.w = voxel_color[gid].a;                                                   // Getting voxel "a" color coordinate...

  float4      V   = velocity[gid];                                              // Current particle velocity.
  float4      A   = acceleration[gid];                                          // Current particle acceleration.

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      m   = mass[gid];                                                  // Current particle mass.
  float4      G   = gravity[gid];                                               // Current particle gravity field.
  float4      c   = friction[gid];                                              // Current particle friction.
  float4      fr  = freedom[gid];                                               //


  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: 1. the index of a non-existing particle friend must be set to the index of the particle.
  long         il_1 = index_friend_1[gid];                                      // Setting indexes of 1st linked particle...
  long         il_2 = index_friend_2[gid];                                      // Setting indexes of 2nd linked particle...
  long         il_3 = index_friend_3[gid];                                      // Setting indexes of 3rd linked particle...
  long         il_4 = index_friend_4[gid];                                      // Setting indexes of 4th linked particle...

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////// SYNERGIC MOLECULE: LINKED PARTICLE POSITIONS /////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Pl_1;                                                             // 1st linked particle position.
  float4      Pl_2;                                                             // 2nd linked particle position.
  float4      Pl_3;                                                             // 3rd linked particle position.
  float4      Pl_4;                                                             // 4th linked particle position.

  Pl_1.x = voxel_point[il_1].x;                                                 // 1st linked particle position.
  Pl_1.y = voxel_point[il_1].y;                                                 // 1st linked particle position.
  Pl_1.z = voxel_point[il_1].z;                                                 // 1st linked particle position.
  Pl_1.w = voxel_point[il_1].w;                                                 // 1st linked particle position.

  Pl_2.x = voxel_point[il_2].x;                                                 // 2nd linked particle position.
  Pl_2.y = voxel_point[il_2].y;                                                 // 2nd linked particle position.
  Pl_2.z = voxel_point[il_2].z;                                                 // 2nd linked particle position.
  Pl_2.w = voxel_point[il_2].w;                                                 // 2nd linked particle position.

  Pl_3.x = voxel_point[il_3].x;                                                 // 3rd linked particle position.
  Pl_3.y = voxel_point[il_3].y;                                                 // 3rd linked particle position.
  Pl_3.z = voxel_point[il_3].z;                                                 // 3rd linked particle position.
  Pl_3.w = voxel_point[il_3].w;                                                 // 3rd linked particle position.

  Pl_4.x = voxel_point[il_4].x;                                                 // 4th linked particle position.
  Pl_4.y = voxel_point[il_4].y;                                                 // 4th linked particle position.
  Pl_4.z = voxel_point[il_4].z;                                                 // 4th linked particle position.
  Pl_4.w = voxel_point[il_4].w;                                                 // 4th linked particle position.

  ////////////////////////////////////////////////////////////////////////////////
  //////////////// SYNERGIC MOLECULE: LINK RESTING DISTANCES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      rl_1 = resting[il_1];                                             // 1st linked particle resting distance.
  float4      rl_2 = resting[il_2];                                             // 2nd linked particle resting distance.
  float4      rl_3 = resting[il_3];                                             // 3rd linked particle resting distance.
  float4      rl_4 = resting[il_4];                                             // 4th linked particle resting distance.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK STIFFNESS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: the stiffness of a non-existing link must reset to 0.
  float4      kl_1 = stiffness[il_1];                                           // 1st link stiffness.
  float4      kl_2 = stiffness[il_2];                                           // 2nd link stiffness.
  float4      kl_3 = stiffness[il_3];                                           // 3rd link stiffness.
  float4      kl_4 = stiffness[il_4];                                           // 4th link stiffness.

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// VERLET INTEGRATION ///////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  // time step
  float dt = DT[gid];

  // linked particles displacements
  float4      Dl_1;
  float4      Dl_2;
  float4      Dl_3;
  float4      Dl_4;

  // Calculating acceleration at time t_n...
  compute_link_displacements(Pl_1, Pl_2, Pl_3, Pl_4, P, rl_1, rl_2, rl_3,
                                  rl_4, fr, &Dl_1, &Dl_2, &Dl_3, &Dl_4);

  float4 F = compute_particle_force(kl_1, kl_2, kl_3, kl_4, Dl_1, Dl_2, Dl_3, Dl_4,
                            c, V, m, G, fr);

  A = F/m;

  // Calculating and updating position of the center particle...
  P += V*dt + A*dt*dt/2.0f;

  // update positions in global memory
  position_int[gid] = P;
  velocity_int[gid] = V;
  acceleration_int[gid] = A;
}
