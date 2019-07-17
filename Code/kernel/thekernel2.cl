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
  unsigned long gid = get_global_id(0);                                          // Setting global index "gid"...

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      P   = position_int[gid];                                              // Current particle position.
  float4      V   = velocity_int[gid];                                              // Current particle velocity.
  float4      A   = acceleration_int[gid];                                          // Current particle acceleration.

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
  ///////////////// SYNERGIC MOLECULE: LINKED PARTICLE POSITIONS /////////////////  t_(n+1)
  ////////////////////////////////////////////////////////////////////////////////
  float4      Pl_1 = position_int[il_1];                                           // 1st linked particle position.
  float4      Pl_2 = position_int[il_2];                                           // 2nd linked particle position.
  float4      Pl_3 = position_int[il_3];                                           // 3rd linked particle position.
  float4      Pl_4 = position_int[il_4];                                           // 4th linked particle position.

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

  // save velocity at time t_n
  float4 Vn = V;

  // compute velocity used for computation of acceleration at t_(n+1)
  V += A*dt;

  // compute new acceleration based on velocity estimate at t_(n+1)
  compute_link_displacements(Pl_1, Pl_2, Pl_3, Pl_4, P, rl_1, rl_2, rl_3,
                                  rl_4, fr, &Dl_1, &Dl_2, &Dl_3, &Dl_4);

  float4 Fnew = compute_particle_force(kl_1, kl_2, kl_3, kl_4, Dl_1, Dl_2, Dl_3, Dl_4,
                            c, V, m, G, fr);

  float4 Anew = Fnew/m;

  // predictor step: velocity at time t_(n+1) based on new forces
  V = Vn + dt*(A+Anew)/2.0f;

  // compute new acceleration based on predicted velocity at t_(n+1)
  Fnew = compute_particle_force(kl_1, kl_2, kl_3, kl_4, Dl_1, Dl_2, Dl_3, Dl_4,
                            c, V, m, G, fr);

  Anew = Fnew/m;

  // corrector step
  V = Vn + dt*(A+Anew)/2.0f;

  // set 4th component to 1
  fix_projective_space(&P);
  fix_projective_space(&V);
  fix_projective_space(&A);

  assign_color(&col, &P);

  // update data arrays in memory (with data at time t_(n+1))
  position[gid] = P;
  velocity[gid] = V;
  acceleration[gid] = A;
  color[gid] = col;
}
