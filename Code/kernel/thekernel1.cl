/// @file
#include "utilities.cl"

__kernel void thekernel(__global point*     position,                           // Position [m].
                        __global color*     depth,                              // Depth color [#]
                        __global float4*    position_int,                       // Position (intermediate) [m].
                        __global float4*    velocity,                           // Velocity [m/s].
                        __global float4*    velocity_int,                       // Velocity (intermediate) [m/s].
                        __global float4*    acceleration,                       // Acceleration [m/s^2].
                        __global float4*    acceleration_int,                   // Acceleration (intermediate) [m/s^2].
                        __global float4*    gravity,                            // Gravity [m/s^2].
                        __global float4*    stiffness,                          // Stiffness
                        __global float4*    resting,                            // Resting distance [m].
                        __global float4*    friction,                           // Friction
                        __global float4*    mass,                               // Mass [kg].
                        __global long*      neighbour_R,                        // Right neighbour [#].
                        __global long*      neighbour_U,                        // Up neighbour [#].
                        __global long*      neighbour_L,                        // Left neighbour [#].
                        __global long*      neighbour_D,                        // Down neighbour [#].
                        __global float4*    freedom,                            // Freedom flag [#].
                        __global float*     dt_simulation)                      // Simulation time step [s].
{

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// GLOBAL INDEX /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned long gid = get_global_id(0);                                         // Global index [#].

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      P;                                                                // Position [m].
  float4      col;                                                              // Depth color [#].
  float4      V;                                                                // Velocity [m/s].
  float4      A;                                                                // Acceleration [m/s^2].

  P.x = position[gid].x;                                                        // Getting "x" point coordinate [m]...
  P.y = position[gid].y;                                                        // Getting "y" point coordinate [m]...
  P.z = position[gid].z;                                                        // Getting "z" point coordinate [m]...
  P.w = position[gid].w;                                                        // Getting "w" point coordinate [m]...

  col.x = depth[gid].r;                                                         // Getting "r" color coordinate [#]...
  col.y = depth[gid].g;                                                         // Getting "g" color coordinate [#]...
  col.z = depth[gid].b;                                                         // Getting "b" color coordinate [#]...
  col.w = depth[gid].a;                                                         // Getting "a" color coordinate [#]...

  V   = velocity[gid];                                                          // Getting velocity [m/s]...
  A   = acceleration[gid];                                                      // Getting acceleration [m/s^2]...

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      m   = mass[gid];                                                  // Current node mass.
  float4      g   = gravity[gid];                                               // Current node gravity field.
  float4      C   = friction[gid];                                              // Current node friction.
  float4      fr  = freedom[gid];                                               // Current freedom flag.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: 1. the index of a non-existing node neighbour must be set to the index of the node.
  long         n_R = neighbour_R[gid];                                          // Setting right neighbour index...
  long         n_U = neighbour_U[gid];                                          // Setting up neighbour index...
  long         n_L = neighbour_L[gid];                                          // Setting left neighbour index...
  long         n_D = neighbour_D[gid];                                          // Setting down neighbour index...

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////// SYNERGIC MOLECULE: LINKED PARTICLE POSITIONS /////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Pl_1;                                                             // Right neighbour position.
  float4      Pl_2;                                                             // Up neighbour position.
  float4      Pl_3;                                                             // Left neighbour position.
  float4      Pl_4;                                                             // Down neighbour position.

  Pl_1.x = position[n_R].x;                                                 // 1st linked node position.
  Pl_1.y = position[n_R].y;                                                 // 1st linked node position.
  Pl_1.z = position[n_R].z;                                                 // 1st linked node position.
  Pl_1.w = position[n_R].w;                                                 // 1st linked node position.

  Pl_2.x = position[n_U].x;                                                 // 2nd linked node position.
  Pl_2.y = position[n_U].y;                                                 // 2nd linked node position.
  Pl_2.z = position[n_U].z;                                                 // 2nd linked node position.
  Pl_2.w = position[n_U].w;                                                 // 2nd linked node position.

  Pl_3.x = position[n_L].x;                                                 // 3rd linked node position.
  Pl_3.y = position[n_L].y;                                                 // 3rd linked node position.
  Pl_3.z = position[n_L].z;                                                 // 3rd linked node position.
  Pl_3.w = position[n_L].w;                                                 // 3rd linked node position.

  Pl_4.x = position[n_D].x;                                                 // 4th linked node position.
  Pl_4.y = position[n_D].y;                                                 // 4th linked node position.
  Pl_4.z = position[n_D].z;                                                 // 4th linked node position.
  Pl_4.w = position[n_D].w;                                                 // 4th linked node position.

  ////////////////////////////////////////////////////////////////////////////////
  //////////////// SYNERGIC MOLECULE: LINK RESTING DISTANCES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      rl_1 = resting[n_R];                                             // 1st linked node resting distance.
  float4      rl_2 = resting[n_U];                                             // 2nd linked node resting distance.
  float4      rl_3 = resting[n_L];                                             // 3rd linked node resting distance.
  float4      rl_4 = resting[n_D];                                             // 4th linked node resting distance.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK STIFFNESS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: the stiffness of a non-existing link must reset to 0.
  float4      kl_1 = stiffness[n_R];                                           // 1st link stiffness.
  float4      kl_2 = stiffness[n_U];                                           // 2nd link stiffness.
  float4      kl_3 = stiffness[n_L];                                           // 3rd link stiffness.
  float4      kl_4 = stiffness[n_D];                                           // 4th link stiffness.

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// VERLET INTEGRATION ///////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  // time step
  float dt = dt_simulation[gid];

  // linked particles displacements
  float4      Dl_1;
  float4      Dl_2;
  float4      Dl_3;
  float4      Dl_4;

  // Calculating acceleration at time t_n...
  compute_link_displacements(Pl_1, Pl_2, Pl_3, Pl_4, P, rl_1, rl_2, rl_3,
                                  rl_4, fr, &Dl_1, &Dl_2, &Dl_3, &Dl_4);

  float4 F = compute_particle_force(kl_1, kl_2, kl_3, kl_4, Dl_1, Dl_2, Dl_3, Dl_4,
                            C, V, m, g, fr);

  A = F/m;

  // Calculating and updating position of the center node...
  P += V*dt + A*dt*dt/2.0f;

  // Updating positions in global memory...
  position_int[gid] = P;
  velocity_int[gid] = V;
  acceleration_int[gid] = A;
}
