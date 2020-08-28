/// @file

__kernel void thekernel(__global float4*    color,                              // Color [#]
                        __global float4*    position,                           // Position [m].
                        __global float4*    position_int,                       // Position (intermediate) [m].
                        __global float4*    velocity,                           // Velocity [m/s].
                        __global float4*    velocity_int,                       // Velocity (intermediate) [m/s].
                        __global float4*    acceleration,                       // Acceleration [m/s^2].
                        __global float4*    acceleration_int,                   // Acceleration (intermediate) [m/s^2].
                        __global float4*    gravity,                            // Gravity [m/s^2].
                        __global float4*    stiffness,                          // Stiffness.
                        __global float4*    resting,                            // Resting distance [m].
                        __global float4*    friction,                           // Friction
                        __global float4*    mass,                               // Mass [kg].
                        __global long*      neighbour,                          // Neighbour.
                        __global long*      offset,                             // Offset.
                        __global float4*    freedom,                            // Freedom flag [#].
                        __global float*     dt_simulation)                      // Simulation time step [s].
{
  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// GLOBAL INDEX /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned long gid = get_global_id(0);                                         // Setting global index "gid"...

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      P   = position_int[gid];                                          // Position (intermediate) [m].
  float4      V   = velocity_int[gid];                                          // Velocity (intermediate) [m/s].
  float4      A   = acceleration_int[gid];                                      // Acceleration (intermediate) [m/s^2].

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      m   = mass[gid];                                                  // Mass [kg].
  float4      g   = gravity[gid];                                               // Gravity [m/s^2]
  float4      C   = friction[gid];                                              // Friction coefficient.
  float4      fr  = freedom[gid];                                               // Freedom flag [#].
  float4      col = depth[gid];                                                 // Current node color.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: 1. the index of a non-existing particle friend must be set to the index of the particle.
  long        n_R = neighbour_R[gid];                                           // Setting right neighbour index [#]...
  long        n_U = neighbour_U[gid];                                           // Setting up neighbour index [#]...
  long        n_L = neighbour_L[gid];                                           // Setting left neighbour index [#]...
  long        n_D = neighbour_D[gid];                                           // Setting down neighbour index [#]...

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////// SYNERGIC MOLECULE: LINKED PARTICLE POSITIONS /////////////////  t_(n+1)
  ////////////////////////////////////////////////////////////////////////////////
  float4      P_R = position_int[n_R];                                          // Right neighbour position [m].
  float4      P_U = position_int[n_U];                                          // Up neighbour position [m].
  float4      P_L = position_int[n_L];                                          // Left neighbour position [m].
  float4      P_D = position_int[n_D];                                          // Down neighbour position [m].

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

  // VELOCITY BACKUP (@ t_n):
  float4      Vn = V;                                                           // Velocity backup [m/s]...

  // NODE FORCE:
  float4      Fnew;                                                             // Node force [N].

  // NODE ACCELERATION:
  float4      Anew;                                                             // NOde acceleration [m/s^2].

  // COMPUTING VELOCITY (for acceleration computation @ t_(n+1)):
  V += A*dt;

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
  Fnew = node_force  (
                              k_R,                                              // Right neighbour stiffness.
                              k_U,                                              // Right neighbour stiffness.
                              k_L,                                              // Right neighbour stiffness.
                              k_D,                                              // Right neighbour stiffness.
                              D_R,                                              // Right neighbour displacement [m].
                              D_U,                                              // Up neighbour displacement [m].
                              D_L,                                              // Left neighbour displacement [m].
                              D_D,                                              // Down neighbour displacement [m].
                              C,                                                // Friction coefficient.
                              V,                                                // Velocity [m/s].
                              m,                                                // Mass [kg].
                              g,                                                // Gravity [m/s^2].
                              fr                                                // Freedom flag [#].
                            );

  // COMPUTING ACCELERATION:
  Anew = Fnew/m;                                                                // Computing acceleration [m/s^2]...

  // PREDICTOR (velocity @ t_(n+1) based on new acceleration):
  V = Vn + dt*(A+Anew)/2.0f;                                                    // Computing velocity [m/s]...

  // COMPUTING NODE FORCE:
  Fnew = node_force  (
                              k_R,                                              // Right neighbour stiffness.
                              k_U,                                              // Right neighbour stiffness.
                              k_L,                                              // Right neighbour stiffness.
                              k_D,                                              // Right neighbour stiffness.
                              D_R,                                              // Right neighbour displacement [m].
                              D_U,                                              // Up neighbour displacement [m].
                              D_L,                                              // Left neighbour displacement [m].
                              D_D,                                              // Down neighbour displacement [m].
                              C,                                                // Friction coefficient.
                              V,                                                // Velocity [m/s].
                              m,                                                // Mass [kg].
                              g,                                                // Gravity [m/s^2].
                              fr                                                // Freedom flag [#].
                              );

  // COMPUTING ACCELERATION:
  Anew = Fnew/m;                                                                // Computing acceleration [m/s^2]...

  // CORRECTOR (velocity @ t_(n+1) based on new acceleration):
  V = Vn + dt*(A+Anew)/2.0f;

  // FIXING PROJECTIVE SPACE:
  fix_projective_space(&P);                                                     // Fixing position [m]...
  fix_projective_space(&V);                                                     // Fixing velocity [m/s]...
  fix_projective_space(&A);                                                     // Fixing acceleration [m/s^2]...

  // ASSIGNING DEPTH COLOR:
  assign_color(&col, &P);                                                       // Assigning depth color [à]...

  // UPDATING KINEMATICS:
  position[gid] = P;                                                            // Updating position [m]...
  velocity[gid] = V;                                                            // Updating velocity [m/s]...
  acceleration[gid] = A;                                                        // UPdating acceleration [m/s^2]...
  depth[gid] = col;                                                             // Updating color [#]...
}
