/// @file
#include "utilities_cl"
#define SAFEDIV(X, Y, FREEDOM)    (X)/(Y + 1.0 - FREEDOM)

__kernel void thekernel(__global float4*    position,                                               // Position [m].
                        __global float4*    color,                                                  // Color [#]
                        __global float4*    position_int,                                           // Position (intermediate) [m].
                        __global float4*    velocity,                                               // Velocity [m/s].
                        __global float4*    velocity_int,                                           // Velocity (intermediate) [m/s].
                        __global float4*    acceleration,                                           // Acceleration [m/s^2].
                        __global float4*    acceleration_int,                                       // Acceleration (intermediate) [m/s^2].
                        __global float*     stiffness,                                              // Stiffness
                        __global float4*    resting,                                                // Resting distance [m].
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
        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////////////// GLOBAL INDEX ///////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        unsigned long gid = get_global_id(0);                                                       // Global index [#].

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 P = position[gid];                                                                   // Getting point coordinates [m]...
        float4 D = depth[gid];                                                                      // Getting color coordinates [#]...
        float4 V = velocity[gid];                                                                   // Getting velocity [m/s]...
        float4 A = acceleration[gid];                                                               // Getting acceleration [m/s^2]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float m   = mass[gid];                                                                      // Current node mass.
        float fr  = freedom[gid];                                                                   // Current freedom flag.

        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the index of a dummy node neighbour must be set to the index of the node.
        long index_R = neighbour_R[gid];                                                            // Setting right neighbour index [#]...
        long index_U = neighbour_U[gid];                                                            // Setting up neighbour index [#]...
        long index_F = neighbour_F[gid];                                                            // Setting front neighbour index [#]...
        long index_L = neighbour_L[gid];                                                            // Setting left neighbour index [#]...
        long index_D = neighbour_D[gid];                                                            // Setting down neighbour index [#]...
        long index_B = neighbour_B[gid];                                                            // Setting back neighbour index [#]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR MASSES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float m_R = m[index_R];                                                                     // Setting right neighbour mass [kg]...
        float m_U = m[index_U];                                                                     // Setting up neighbour mass [kg]...
        float m_F = m[index_F];                                                                     // Setting front neighbour mass [kg]...
        float m_L = m[index_L];                                                                     // Setting left neighbour mass [kg]...
        float m_D = m[index_D];                                                                     // Setting down neighbour mass [kg]...
        float m_B = m[index_B];                                                                     // Setting back neighbour mass [kg]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR POSITIONS /////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 position_R = position[index_R];                                                      // Setting right neighbour position coordinates [m]...
        float4 position_U = position[index_U];                                                      // Setting up neighbour position coordinates [m]...
        float4 position_F = position[index_F];                                                      // Setting front neighbour position coordinates [m]...
        float4 position_L = position[index_L];                                                      // Setting left neighbour position coordinates [m]...
        float4 position_D = position[index_D];                                                      // Setting down neighbour position coordinates [m]...
        float4 position_B = position[index_B];                                                      // Setting back neighbour position coordinates [m]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////// SYNERGIC MOLECULE: RESTING POSITIONS //////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 resting_R = (float4)(resting[gid].x, 0.0, 0.0, resting[gid].w);                      // Setting right resting position [m]...
        float4 resting_U = (float4)(0.0, resting[gid].y, 0.0, resting[gid].w);                      // Setting up neighbour position coordinates [m]...
        float4 resting_F = (float4)(0.0, 0.0, resting[gid].z, resting[gid].w);                      // Setting front neighbour position coordinates [m]...
        float4 resting_L = (float4)(-resting[gid].x, 0.0, 0.0, resting[gid].w);                     // Setting left neighbour position coordinates [m]...
        float4 resting_D = (float4)(0.0, -resting[gid].y, 0.0, resting[gid].w);                     // Setting down neighbour position coordinates [m]...
        float4 resting_B = (float4)(0.0, 0.0, -resting[gid].z, resting[gid].w);                     // Setting back neighbour position coordinates [m]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////// SYNERGIC MOLECULE: LINK VECTORS ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 link_R = position_R - P;                                                             // Right neighbour link vector.
        float4 link_U = position_U - P;                                                             // Up neighbour link vector.
        float4 link_F = position_F - P;                                                             // Front neighbour link vector.
        float4 link_L = position_L - P;                                                             // Left neighbour link vector.
        float4 link_D = position_D - P;                                                             // Down neighbour link vector.
        float4 link_B = position_B - P;                                                             // Back neighbour link vector.

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////// SYNERGIC MOLECULE: LINK LENGTH ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float length_R = length(link_R);                                                            // Right neighbour link length.
        float length_U = length(link_U);                                                            // Up neighbour link length.
        float length_F = length(link_F);                                                            // Front neighbour link length.
        float length_L = length(link_L);                                                            // Left neighbour link length.
        float length_D = length(link_D);                                                            // Down neighbour link length.
        float length_B = length(link_B);                                                            // Back neighbour link length.

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////// SYNERGIC MOLECULE: LINK STRAIN ////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float strain_R = strain(length_R, resting_R, R0, Rmax);                                     // Right neighbour link strain.
        float strain_U = strain(length_U, resting_U, R0, Rmax);                                     // Up neighbour link strain.
        float strain_F = strain(length_F, resting_F, R0, Rmax);                                     // Front neighbour link strain.
        float strain_L = strain(length_L, resting_L, R0, Rmax);                                     // Left neighbour link strain.
        float strain_D = strain(length_D, resting_D, R0, Rmax);                                     // Down neighbour link strain.
        float strain_B = strain(length_B, resting_B, R0, Rmax);                                     // Back neighbour link strain.

        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT /////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 displacement_R = position_R - P + resting_R;                                                    // Right neighbour link displacement.
        float4 displacement_U = strain_U*link_U;                                                    // Up neighbour link displacement.
        float4 displacement_F = strain_U*link_F;                                                    // Front neighbour link displacement.
        float4 displacement_L = strain_U*link_L;                                                    // Left neighbour link displacement.
        float4 displacement_D = strain_U*link_D;                                                    // Down neighbour link displacement.
        float4 displacement_B = strain_U*link_B;                                                    // Back neighbour link displacement.

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR VELOCITIES ////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 velocity_R = velocity[index_R];                                                      // Setting right neighbour velocity coordinates [m]...
        float4 velocity_U = velocity[index_U];                                                      // Setting up neighbour velocity coordinates [m]...
        float4 velocity_F = velocity[index_F];                                                      // Setting front neighbour velocity coordinates [m]...
        float4 velocity_L = velocity[index_L];                                                      // Setting left neighbour velocity coordinates [m]...
        float4 velocity_D = velocity[index_D];                                                      // Setting down neighbour velocity coordinates [m]...
        float4 velocity_B = velocity[index_B];                                                      // Setting back neighbour velocity coordinates [m]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR DISPATCHES ////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 dispatch_R = velocity_R - V;                                                         // Right neighbour dispatch [m/s].
        float4 dispatch_U = velocity_U - V;                                                         // Up neighbour dispatch [m/s].
        float4 dispatch_F = velocity_F - V;                                                         // Front neighbour dispatch [m/s].
        float4 dispatch_L = velocity_L - V;                                                         // Left neighbour dispatch [m/s].
        float4 dispatch_D = velocity_D - V;                                                         // Down neighbour dispatch [m/s].
        float4 dispatch_B = velocity_B - V;                                                         // Back neighbour dispatch [m/s].

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// SYNERGIC MOLECULE: LINK STIFFNESS ////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the stiffness of a dummy zero-length link must be 0.
        float stiffness_R = stiffness[index_R];                                                     // Setting right neighbour stiffness...
        float stiffness_U = stiffness[index_U];                                                     // Setting up neighbour stiffness...
        float stiffness_F = stiffness[index_F];                                                     // Setting front neighbour stiffness...
        float stiffness_L = stiffness[index_L];                                                     // Setting left neighbour stiffness...
        float stiffness_D = stiffness[index_D];                                                     // Setting down neighbour stiffness...
        float stiffness_B = stiffness[index_B];                                                     // Setting back neighbour stiffness...

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// SYNERGIC MOLECULE: LINK FRICTION /////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the friction of a dummy zero-length link must be 0.
        float friction_R = friction[index_R];                                                       // Setting right neighbour friction...
        float friction_U = friction[index_U];                                                       // Setting up neighbour friction...
        float friction_F = friction[index_F];                                                       // Setting front neighbour friction...
        float friction_L = friction[index_L];                                                       // Setting left neighbour friction...
        float friction_D = friction[index_D];                                                       // Setting down neighbour friction...
        float friction_B = friction[index_B];                                                       // Setting back neighbour friction...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: ELASTIC FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 Fe = (
                stiffness_R*displacement_R +
                stiffness_U*displacement_U +
                stiffness_F*displacement_F +
                stiffness_L*displacement_L +
                stiffness_D*displacement_D +
                stiffness_B*displacement_B
                );

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: VISCOUS FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // Elastic force applied to the particle:
        float4 Fv = -(
                friction_R*dispatch_R +
                friction_U*dispatch_U+
                friction_F*dispatch_F+
                friction_L*dispatch_L+
                friction_D*dispatch_D+
                friction_B*dispatch_B
                );

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////// SYNERGIC MOLECULE: GRAVITATIONAL FORCE ////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 Fg = -(
                m*m_R*gravity(length_R, R0)*normalize(link_R) +
                m*m_U*gravity(length_U, R0)*normalize(link_U) +
                m*m_F*gravity(length_F, R0)*normalize(link_F) +
                m*m_L*gravity(length_L, R0)*normalize(link_L) +
                m*m_D*gravity(length_D, R0)*normalize(link_D) +
                m*m_B*gravity(length_B, R0)*normalize(link_B)
                );

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////// SYNERGIC MOLECULE: TOTAL FORCE ////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 F    = fr*(Fe + Fv + Fg);                                                            // Total force applied to the particle [N].

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////// VERLET INTEGRATION ///////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // COMPUTING ACCELERATION:
        A = F/m;                                                                // Computing acceleration [m/s^2]...

        // UPDATING POSITION:
        P += V*dt + A*dt*dt/2.0;                                               // Updating position [m]...

        // UPDATING INTERMEDIATE KINEMATICS:
        position_int[gid] = P;                                                  // Updating position (intermediate) [m]...
        velocity_int[gid] = V;                                                  // Updating position (intermediate) [m/s]...
        acceleration_int[gid] = A;                                              // Updating position (intermediate) [m/s^2]...
}
