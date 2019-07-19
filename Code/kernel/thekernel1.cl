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
  long        n_R = neighbour_R[gid];                                           // Setting right neighbour index [#]...
  long        n_U = neighbour_U[gid];                                           // Setting up neighbour index [#]...
  long        n_L = neighbour_L[gid];                                           // Setting left neighbour index [#]...
  long        n_D = neighbour_D[gid];                                           // Setting down neighbour index [#]...

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////// SYNERGIC MOLECULE: LINKED PARTICLE POSITIONS /////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      P_R;                                                              // Right neighbour position [m].
  float4      P_U;                                                              // Up neighbour position [m].
  float4      P_L;                                                              // Left neighbour position [m].
  float4      P_D;                                                              // Down neighbour position [m].

  P_R.x = position[n_R].x;                                                      // Setting right neighbour "x" position coordinate [m]...
  P_R.y = position[n_R].y;                                                      // Setting right neighbour "x" position coordinate [m]...
  P_R.z = position[n_R].z;                                                      // Setting right neighbour "x" position coordinate [m]...
  P_R.w = position[n_R].w;                                                      // Setting right neighbour "x" position coordinate [m]...

  P_U.x = position[n_U].x;                                                      // Setting up neighbour "y" position coordinate [m]...
  P_U.y = position[n_U].y;                                                      // Setting up neighbour "y" position coordinate [m]...
  P_U.z = position[n_U].z;                                                      // Setting up neighbour "y" position coordinate [m]...
  P_U.w = position[n_U].w;                                                      // Setting up neighbour "y" position coordinate [m]...

  P_L.x = position[n_L].x;                                                      // Setting left neighbour "z" position coordinate [m]...
  P_L.y = position[n_L].y;                                                      // Setting left neighbour "z" position coordinate [m]...
  P_L.z = position[n_L].z;                                                      // Setting left neighbour "z" position coordinate [m]...
  P_L.w = position[n_L].w;                                                      // Setting left neighbour "z" position coordinate [m]...

  P_D.x = position[n_D].x;                                                      // Setting down neighbour "w" position coordinate [m]...
  P_D.y = position[n_D].y;                                                      // Setting down neighbour "w" position coordinate [m]...
  P_D.z = position[n_D].z;                                                      // Setting down neighbour "w" position coordinate [m]...
  P_D.w = position[n_D].w;                                                      // Setting down neighbour "w" position coordinate [m]...

  ////////////////////////////////////////////////////////////////////////////////
  //////////////// SYNERGIC MOLECULE: LINK RESTING DISTANCES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      resting_R = resting[n_R];                                         // Setting right neighbour resting position [m]...
  float4      resting_U = resting[n_U];                                         // Setting up neighbour resting position [m]...
  float4      resting_L = resting[n_L];                                         // Setting left neighbour resting position [m]...
  float4      resting_D = resting[n_D];                                         // Setting down neighbour resting position [m]...

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK STIFFNESS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: the stiffness of a non-existing link must reset to 0.
  float4      k_R = stiffness[n_R];                                             // Setting right neighbour stiffness...
  float4      k_U = stiffness[n_U];                                             // Setting up neighbour stiffness...
  float4      k_L = stiffness[n_L];                                             // Setting left neighbour stiffness...
  float4      k_D = stiffness[n_D];                                             // Setting down neighbour stiffness...

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// VERLET INTEGRATION ///////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  // TIME STEP:
  float dt = dt_simulation[gid];                                                // Setting simulation time step [s]...

  // NEIGHBOURS DISPLACEMENTS:
  float4      D_R;                                                              // Right neighbour displacement [m]...
  float4      D_U;                                                              // Up neighbour displacement [m]...
  float4      D_L;                                                              // Left neighbour displacement [m]...
  float4      D_D;                                                              // Down neighbour displacement [m]...

  // COMPUTING LINK DISPLACEMENTS:
  link_displacements(
                      P_R,                                                      // Right neighbour position [m].
                      P_U,                                                      // Up neighbour position [m].
                      P_L,                                                      // Left neighbour position [m].
                      P_D,                                                      // Down neighbour position [m].
                      P,                                                        // Position [m].
                      resting_R,                                                // Right neighbour resting position [m].
                      resting_U,                                                // Up neighbour resting position [m].
                      resting_L,                                                // Left neighbour resting position [m].
                      resting_D,                                                // Down neighbour resting position [m].
                      fr,                                                       // Freedom flag [#].
                      &D_R,                                                     // Right neighbour displacement [m].
                      &D_U,                                                     // Up neighbour displacement [m].
                      &D_L,                                                     // Left neighbour displacement [m].
                      &D_D                                                      // Down neighbour displacement [m].
                    );

  // COMPUTING NODE FORCE:
  float4 F = node_force (
                          k_R,                                                  // Right neighbour stiffness.
                          k_U,                                                  // Right neighbour stiffness.
                          k_L,                                                  // Right neighbour stiffness.
                          k_D,                                                  // Right neighbour stiffness.
                          D_R,                                                  // Right neighbour displacement [m].
                          D_U,                                                  // Up neighbour displacement [m].
                          D_L,                                                  // Left neighbour displacement [m].
                          D_D,                                                  // Down neighbour displacement [m].
                          C,                                                    // Friction coefficient.
                          V,                                                    // Velocity [m/s].
                          m,                                                    // Mass [kg].
                          g,                                                    // Gravity [m/s^2].
                          fr                                                    // Freedom flag [#].
                        );

  // COMPUTING ACCELERATION:
  A = F/m;                                                                      // Computing acceleration [m/s^2]...

  // UPDATING POSITION:
  P += V*dt + A*dt*dt/2.0f;                                                     // Updating position [m]...

  // UPDATING INTERMEDIATE KINEMATICS:
  position_int[gid] = P;                                                        // Updating position (intermediate) [m]...
  velocity_int[gid] = V;                                                        // Updating position (intermediate) [m/s]...
  acceleration_int[gid] = A;                                                    // Updating position (intermediate) [m/s^2]...
}
