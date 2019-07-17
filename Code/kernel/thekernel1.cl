/// @file
#include "utilities.cl"

__kernel void thekernel(__global float4*    position,
                        __global float4*    color,
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
                        __global long*       index_friend_1,                     // Indexes of "#1 friend" particles.
                        __global long*       index_friend_2,                     // Indexes of "#2 friend" particles.
                        __global long*       index_friend_3,                     // Indexes of "#3 friend" particles.
                        __global long*       index_friend_4,                     // Indexes of "#4 friend" particles.
                        __global float4*    freedom,
                        __global float*     DT)
{

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// GLOBAL INDEX /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned long gid = get_global_id(0);                                          // Setting global index "gid"...

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      P   = position[gid];                                              // Current particle position.
  float4      V   = velocity[gid];                                              // Current particle velocity.
  float4      A   = acceleration[gid];                                          // Current particle acceleration.

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      m   = mass[gid];                                                  // Current particle mass.
  float4      G   = gravity[gid];                                               // Current particle gravity field.
  float4      c   = friction[gid];                                              // Current particle friction.
  float4      fr  = freedom[gid];                                               //
  float4      col = color[gid];                                                 // Current particle color.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: 1. the index of a non-existing particle friend must be set to the index of the particle.
  long         il_1 = index_friend_1[gid];                                       // Setting indexes of 1st linked particle...
  long         il_2 = index_friend_2[gid];                                       // Setting indexes of 2nd linked particle...
  long         il_3 = index_friend_3[gid];                                       // Setting indexes of 3rd linked particle...
  long         il_4 = index_friend_4[gid];                                       // Setting indexes of 4th linked particle...

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////// SYNERGIC MOLECULE: LINKED PARTICLE POSITIONS /////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Pl_1 = position[il_1];                                           // 1st linked particle position.
  float4      Pl_2 = position[il_2];                                           // 2nd linked particle position.
  float4      Pl_3 = position[il_3];                                           // 3rd linked particle position.
  float4      Pl_4 = position[il_4];                                           // 4th linked particle position.

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
  float dt = *DT;

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
