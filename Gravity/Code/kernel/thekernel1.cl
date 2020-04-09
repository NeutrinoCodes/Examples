/// @file
#include "utilities.cl"

__kernel void thekernel(__global float4*    position,                                               // Position [m].
                        __global float4*    color,                                                  // Color [#]
                        __global float4*    position_int,                                           // Position (intermediate) [m].
                        __global float4*    velocity,                                               // Velocity [m/s].
                        __global float4*    velocity_int,                                           // Velocity (intermediate) [m/s].
                        __global float4*    acceleration,                                           // Acceleration [m/s^2].
                        __global float4*    acceleration_int,                                       // Acceleration (intermediate) [m/s^2].
                        __global float*     stiffness,                                              // Stiffness
                        __global float*     resting,                                                // Resting distance [m].
                        __global float*     friction,                                               // Friction
                        __global float*     mass,                                                   // Mass [kg].
                        __global long*      neighbour_R,                                            // Right neighbour [#].
                        __global long*      neighbour_U,                                            // Up neighbour [#].
                        __global long*      neighbour_F,                                            // Front neighbour [#].
                        __global long*      neighbour_L,                                            // Left neighbour [#].
                        __global long*      neighbour_D,                                            // Down neighbour [#].
                        __global long*      neighbour_B,                                            // Back neighbour [#].
                        __global float*     freedom,                                                // Freedom flag [#].
                        float dt)                                                                   // Simulation time step [s].
{
        ////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// GLOBAL INDEX /////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        unsigned long gid = get_global_id(0);                                   // Global index [#].

        ////////////////////////////////////////////////////////////////////////////////
        /////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES /////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 P = position[gid];                                               // Getting point coordinates [m]...
        float4 D = depth[gid];                                                  // Getting color coordinates [#]...
        float4 V = velocity[gid];                                               // Getting velocity [m/s]...
        float4 A = acceleration[gid];                                           // Getting acceleration [m/s^2]...

        ////////////////////////////////////////////////////////////////////////////////
        /////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float m   = mass[gid];                                                 // Current node mass.
        float C   = friction[gid];                                             // Current node friction.
        float fr  = freedom[gid];                                              // Current freedom flag.

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        // NOTE: 1. the index of a non-existing node neighbour must be set to the index of the node.
        long index_R = neighbour_R[gid];                                        // Setting right neighbour index [#]...
        long index_U = neighbour_U[gid];                                        // Setting up neighbour index [#]...
        long index_F = neighbour_F[gid];                                        // Setting front neighbour index [#]...
        long index_L = neighbour_L[gid];                                        // Setting left neighbour index [#]...
        long index_D = neighbour_D[gid];                                        // Setting down neighbour index [#]...
        long index_B = neighbour_B[gid];                                        // Setting back neighbour index [#]...

        ////////////////////////////////////////////////////////////////////////////////
        ///////////////// SYNERGIC MOLECULE: LINKED PARTICLE POSITIONS /////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 position_R = position[index_R];                                  // Setting right neighbour position coordinates [m]...
        float4 position_U = position[index_U];                                  // Setting up neighbour position coordinates [m]...
        float4 position_F = position[index_F];                                  // Setting front neighbour position coordinates [m]...
        float4 position_L = position[index_L];                                  // Setting left neighbour position coordinates [m]...
        float4 position_D = position[index_D];                                  // Setting down neighbour position coordinates [m]...
        float4 position_B = position[index_B];                                  // Setting back neighbour position coordinates [m]...

        ////////////////////////////////////////////////////////////////////////////////
        //////////////// SYNERGIC MOLECULE: LINK RESTING DISTANCES /////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 resting_R = resting[index_R];                                    // Setting right neighbour resting position [m]...
        float4 resting_U = resting[index_U];                                    // Setting up neighbour resting position [m]...
        float4 resting_F = resting[index_F];                                    // Setting front neighbour resting position [m]...
        float4 resting_L = resting[index_L];                                    // Setting left neighbour resting position [m]...
        float4 resting_D = resting[index_D];                                    // Setting down neighbour resting position [m]...
        float4 resting_B = resting[index_B];                                    // Setting back neighbour resting position [m]...

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////// SYNERGIC MOLECULE: LINK STIFFNESS ///////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        // NOTE: the stiffness of a non-existing link must reset to 0.
        float4 stiffness_R = stiffness[index_R];                                // Setting right neighbour stiffness...
        float4 stiffness_U = stiffness[index_U];                                // Setting up neighbour stiffness...
        float4 stiffness_F = stiffness[index_F];                                // Setting front neighbour stiffness...
        float4 stiffness_L = stiffness[index_L];                                // Setting left neighbour stiffness...
        float4 stiffness_D = stiffness[index_D];                                // Setting down neighbour stiffness...
        float4 stiffness_B = stiffness[index_B];                                // Setting back neighbour stiffness...

        ////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// VERLET INTEGRATION /////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float dt = dt_simulation[gid];                                          // Setting simulation time step [s]...

        float4 displacement_R;                                                  // Right neighbour displacement [m]...
        float4 displacement_U;                                                  // Up neighbour displacement [m]...
        float4 displacement_F;                                                  // Front neighbour displacement [m]...
        float4 displacement_L;                                                  // Left neighbour displacement [m]...
        float4 displacement_D;                                                  // Down neighbour displacement [m]...
        float4 displacement_B;                                                  // Back neighbour displacement [m]...

        float4 F;                                                               // Force [N].

        // COMPUTING LINK DISPLACEMENTS:
        link_displacements(
                P,                                                              // Position [m].
                position_R,                                                     // Right neighbour position [m].
                position_U,                                                     // Up neighbour position [m].
                position_F,                                                     // Front neighbour position [m].
                position_L,                                                     // Left neighbour position [m].
                position_D,                                                     // Down neighbour position [m].
                position_B,                                                     // Back neighbour position [m].
                resting_R,                                                      // Right neighbour resting position [m].
                resting_U,                                                      // Up neighbour resting position [m].
                resting_F,                                                      // Front neighbour resting position [m].
                resting_L,                                                      // Left neighbour resting position [m].
                resting_D,                                                      // Down neighbour resting position [m].
                resting_B,                                                      // Back neighbour resting position [m].
                &displacement_R,                                                // Right neighbour displacement [m].
                &displacement_U,                                                // Up neighbour displacement [m].
                &displacement_F,                                                // Front neighbour displacement [m].
                &displacement_L,                                                // Left neighbour displacement [m].
                &displacement_D,                                                // Down neighbour displacement [m].
                &displacement_B                                                 // Back neighbour displacement [m].
                );

        // COMPUTING NODE FORCE:
        F = node_force (
                stiffness_R,                                                    // Right neighbour stiffness.
                stiffness_U,                                                    // Up neighbour stiffness.
                stiffness_F,                                                    // Front neighbour stiffness.
                stiffness_L,                                                    // Left neighbour stiffness.
                stiffness_D,                                                    // Down neighbour stiffness.
                stiffness_B,                                                    // Back neighbour stiffness.
                displacement_R,                                                 // Right neighbour displacement [m].
                displacement_U,                                                 // Up neighbour displacement [m].
                displacement_F,                                                 // Front neighbour displacement [m].
                displacement_L,                                                 // Left neighbour displacement [m].
                displacement_D,                                                 // Down neighbour displacement [m].
                displacement_B,                                                 // Back neighbour displacement [m].
                C,                                                              // Friction coefficient.
                V,                                                              // Velocity [m/s].
                m,                                                              // Mass [kg].
                g,                                                              // Gravity [m/s^2].
                fr                                                              // Freedom flag [#].
                );

        // COMPUTING ACCELERATION:
        A = F/m;                                                                // Computing acceleration [m/s^2]...

        // UPDATING POSITION:
        P += V*dt + A*dt*dt/2.0f;                                               // Updating position [m]...

        // UPDATING INTERMEDIATE KINEMATICS:
        position_int[gid] = P;                                                  // Updating position (intermediate) [m]...
        velocity_int[gid] = V;                                                  // Updating position (intermediate) [m/s]...
        acceleration_int[gid] = A;                                              // Updating position (intermediate) [m/s^2]...
}
