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
                        __global float*     radius,                                                 // Particle radius [m].
                        __global float*     time)                                                   // Simulation time step [s].
{
        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////////////// GLOBAL INDEX ///////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        unsigned long gid = get_global_id(0);                                                       // Global index [#].

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 p = position_int[gid];                                                               // Getting point coordinates [m]...
        float4 v = velocity_int[gid];                                                               // Getting velocity [m/s]...
        float4 a = acceleration_int[gid];                                                           // Getting acceleration [m/s^2]...
        float4 a_new;                                                                               // New acceleration [m/s^2]...
        float4 c = color[gid];                                                                      // Getting color coordinates [#]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float m   = mass[gid];                                                                      // Current node mass.
        float fr  = freedom[gid];                                                                   // Current freedom flag.
        float dt  = time[gid];                                                                      // Current dt.
        float R0  = radius[gid];                                                                    // Current particle radius.
        float4 F_new;

        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the index of a dummy node neighbour must be set to the index of the node.
        long i_R = neighbour_R[gid];                                                                // Setting right neighbour index [#]...
        long i_U = neighbour_U[gid];                                                                // Setting up neighbour index [#]...
        long i_F = neighbour_F[gid];                                                                // Setting front neighbour index [#]...
        long i_L = neighbour_L[gid];                                                                // Setting left neighbour index [#]...
        long i_D = neighbour_D[gid];                                                                // Setting down neighbour index [#]...
        long i_B = neighbour_B[gid];                                                                // Setting back neighbour index [#]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR MASSES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float m_R = mass[i_R];                                                                         // Setting right neighbour mass [kg]...
        float m_U = mass[i_U];                                                                         // Setting up neighbour mass [kg]...
        float m_F = mass[i_F];                                                                         // Setting front neighbour mass [kg]...
        float m_L = mass[i_L];                                                                         // Setting left neighbour mass [kg]...
        float m_D = mass[i_D];                                                                         // Setting down neighbour mass [kg]...
        float m_B = mass[i_B];                                                                         // Setting back neighbour mass [kg]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR POSITIONS /////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 p_R = position_int[i_R];                                                             // Setting right neighbour position coordinates [m]...
        float4 p_U = position_int[i_U];                                                             // Setting up neighbour position coordinates [m]...
        float4 p_F = position_int[i_F];                                                             // Setting front neighbour position coordinates [m]...
        float4 p_L = position_int[i_L];                                                             // Setting left neighbour position coordinates [m]...
        float4 p_D = position_int[i_D];                                                             // Setting down neighbour position coordinates [m]...
        float4 p_B = position_int[i_B];                                                             // Setting back neighbour position coordinates [m]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////// SYNERGIC MOLECULE: NEIGHBOUR RESTING DISTANCES /////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float r_R_mag = resting[i_R].x;                                                             // Setting right neighbour position coordinates [m]...
        float r_U_mag = resting[i_U].y;                                                             // Setting up neighbour position coordinates [m]...
        float r_F_mag = resting[i_F].z;                                                             // Setting front neighbour position coordinates [m]...
        float r_L_mag = resting[i_L].x;                                                             // Setting left neighbour position coordinates [m]...
        float r_D_mag = resting[i_D].y;                                                             // Setting down neighbour position coordinates [m]...
        float r_B_mag = resting[i_B].z;                                                             // Setting back neighbour position coordinates [m]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////// SYNERGIC MOLECULE: LINK VECTORS ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 l_R = p_R - p;                                                                       // Right neighbour link vector.
        float4 l_U = p_U - p;                                                                       // Up neighbour link vector.
        float4 l_F = p_F - p;                                                                       // Front neighbour link vector.
        float4 l_L = p_L - p;                                                                       // Left neighbour link vector.
        float4 l_D = p_D - p;                                                                       // Down neighbour link vector.
        float4 l_B = p_B - p;                                                                       // Back neighbour link vector.

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////// SYNERGIC MOLECULE: LINK LENGTH ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float l_R_mag = length(l_R);                                                                // Right neighbour link length.
        float l_U_mag = length(l_U);                                                                // Up neighbour link length.
        float l_F_mag = length(l_F);                                                                // Front neighbour link length.
        float l_L_mag = length(l_L);                                                                // Left neighbour link length.
        float l_D_mag = length(l_D);                                                                // Down neighbour link length.
        float l_B_mag = length(l_B);                                                                // Back neighbour link length.

        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT /////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 dp_R;                                                                                // Right neighbour link displacement.
        float4 dp_U;                                                                                // Up neighbour link displacement.
        float4 dp_F;                                                                                // Front neighbour link displacement.
        float4 dp_L;                                                                                // Left neighbour link displacement.
        float4 dp_D;                                                                                // Down neighbour link displacement.
        float4 dp_B;                                                                                // Back neighbour link displacement.

        if(l_R_mag > 0.0f)
        {
                dp_R = (l_R_mag - r_R_mag)*normalize(l_R);                                          // Right neighbour link displacement.
        }
        else
        {
                dp_R = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                            // Right neighbour link displacement.
        }

        if(l_U_mag > 0.0f)
        {
                dp_U = (l_U_mag - r_U_mag)*normalize(l_U);                                          // Up neighbour link displacement.
        }
        else
        {
                dp_U = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                            // Up neighbour link displacement.
        }

        if(l_F_mag > 0.0f)
        {
                dp_F = (l_F_mag - r_F_mag)*normalize(l_F);                                          // Front neighbour link displacement.
        }
        else
        {
                dp_F = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                            // Front neighbour link displacement.
        }

        if(l_L_mag > 0.0f)
        {
                dp_L = (l_L_mag - r_L_mag)*normalize(l_L);                                          // Left neighbour link displacement.
        }
        else
        {
                dp_L = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                            // Left neighbour link displacement.
        }

        if(l_D_mag > 0.0f)
        {
                dp_D = (l_D_mag - r_D_mag)*normalize(l_D);                                          // Down neighbour link displacement.
        }
        else
        {
                dp_D = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                            // Down neighbour link displacement.
        }

        if(l_B_mag > 0.0f)
        {
                dp_B = (l_B_mag - r_B_mag)*normalize(l_B);                                          // Back neighbour link displacement.
        }
        else
        {
                dp_B = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                            // Back neighbour link displacement.
        }

        float4 v_old = v;                                                                           // Velocity backup [m/s]...
        v += a*dt;                                                                                  // Velocity estimation for acceleration computation @ t_(n+1)...

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// SYNERGIC MOLECULE: LINK STIFFNESS ////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the stiffness of a dummy zero-length link must be 0.
        float K = stiffness[gid];                                                                   // Setting link stiffness...

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// SYNERGIC MOLECULE: LINK FRICTION /////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the friction of a dummy zero-length link must be 0.
        float B = friction[gid];                                                                    // Setting particle friction...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: ELASTIC FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 Fe = K*(dp_R + dp_U + dp_F + dp_L + dp_D + dp_B);                                    // Computing elastic force [N]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: VISCOUS FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // Elastic force applied to the particle:
        float4 Fv = -B*v;                                                                           // Computing friction force [N]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////// SYNERGIC MOLECULE: GRAVITATIONAL FORCE ////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 Fg;

        p.w = 0.0f;

        if((m > 0.0f) && (length(p) > R0))
        {
                Fg = -(m*10.0f/pown(length(p), 2))*normalize(p);                                     // Computing gravitational force [N]...
                F_new    = fr*(Fe + Fv + Fg);                                                       // Total force applied to the particle [N]...
                a_new = F_new/m;                                                                    // Computing acceleration [m/s^2]...

                // PREDICTOR (velocity @ t_(n+1) based on new acceleration):
                v = v_old + dt*(a + a_new)/2.0f;                                                    // Computing velocity [m/s]...
        }
        else
        {
                a = (float4)(0.0f, 0.0f, 0.0f, 1.0f);
                v = (float4)(0.0f, 0.0f, 0.0f, 1.0f);
        }

        p.w = 1.0f;

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: VISCOUS FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // Elastic force applied to the particle:
        Fv = -B*v;                                                                                  // Computing friction force [N]...

        p.w = 0.0f;

        if((m > 0.0f) && (length(p) > R0))
        {
                Fg = -(m*10.0f/pown(length(p), 2))*normalize(p);                                     // Computing gravitational force [N]...
                F_new    = fr*(Fe + Fv + Fg);                                                       // Total force applied to the particle [N]...
                a_new = F_new/m;                                                                    // Computing acceleration [m/s^2]...

                // PREDICTOR (velocity @ t_(n+1) based on new acceleration):
                v = v_old + dt*(a + a_new)/2.0f;                                                    // Computing velocity [m/s]...
        }
        else
        {
                a = (float4)(0.0f, 0.0f, 0.0f, 1.0f);
                v = (float4)(0.0f, 0.0f, 0.0f, 1.0f);
        }

        p.w = 1.0f;

        // ASSIGNING COLOR:
        c.x = (curv3D(p, p_R, p_U, p_F, p_L, p_D, p_B));

        // FIXING PROJECTIVE SPACE:
        p.w = 1.0f;
        v.w = 1.0f;
        a.w = 1.0f;

        // UPDATING KINEMATICS:
        position[gid] = p;                                                                          // Updating position [m]...
        velocity[gid] = v;                                                                          // Updating velocity [m/s]...
        acceleration[gid] = a;                                                                      // Updating acceleration [m/s^2]...
        color[gid] = c;                                                                             // Updating color [#]...
}
