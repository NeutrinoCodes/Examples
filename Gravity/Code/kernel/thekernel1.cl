/// @file

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
        unsigned long gid = get_global_id(0);                                                           // Global index [#].

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 p = position[gid];                                                                       // Getting point coordinates [m]...
        float4 v = velocity[gid];                                                                       // Getting velocity [m/s]...
        float4 a = acceleration[gid];                                                                   // Getting acceleration [m/s^2]...
        float4 c = color[gid];                                                                          // Getting color coordinates [#]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float m   = mass[gid];                                                                          // Current node mass.
        float fr  = freedom[gid];                                                                       // Current freedom flag.
        float dt  = time[gid];                                                                          // Current dt.
        float R0  = radius[gid];                                                                        // Current particle radius.

        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the index of a dummy node neighbour must be set to the index of the node.
        long i_R = neighbour_R[gid];                                                                       // Setting right neighbour index [#]...
        long i_U = neighbour_U[gid];                                                                       // Setting up neighbour index [#]...
        long i_F = neighbour_F[gid];                                                                       // Setting front neighbour index [#]...
        long i_L = neighbour_L[gid];                                                                       // Setting left neighbour index [#]...
        long i_D = neighbour_D[gid];                                                                       // Setting down neighbour index [#]...
        long i_B = neighbour_B[gid];                                                                       // Setting back neighbour index [#]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR MASSES ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float m_R = mass[i_R];                                                                                // Setting right neighbour mass [kg]...
        float m_U = mass[i_U];                                                                                // Setting up neighbour mass [kg]...
        float m_F = mass[i_F];                                                                                // Setting front neighbour mass [kg]...
        float m_L = mass[i_L];                                                                                // Setting left neighbour mass [kg]...
        float m_D = mass[i_D];                                                                                // Setting down neighbour mass [kg]...
        float m_B = mass[i_B];                                                                                // Setting back neighbour mass [kg]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR POSITIONS /////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 p_R = position[i_R];                                                                        // Setting right neighbour position coordinates [m]...
        float4 p_U = position[i_U];                                                                        // Setting up neighbour position coordinates [m]...
        float4 p_F = position[i_F];                                                                        // Setting front neighbour position coordinates [m]...
        float4 p_L = position[i_L];                                                                        // Setting left neighbour position coordinates [m]...
        float4 p_D = position[i_D];                                                                        // Setting down neighbour position coordinates [m]...
        float4 p_B = position[i_B];                                                                        // Setting back neighbour position coordinates [m]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////// SYNERGIC MOLECULE: NEIGHBOUR RESTING DISTANCES /////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float r_R_mag = resting[i_R].x;                                                          // Setting right neighbour position coordinates [m]...
        float r_U_mag = resting[i_U].y;                                                          // Setting up neighbour position coordinates [m]...
        float r_F_mag = resting[i_F].z;                                                          // Setting front neighbour position coordinates [m]...
        float r_L_mag = resting[i_L].x;                                                          // Setting left neighbour position coordinates [m]...
        float r_D_mag = resting[i_D].y;                                                          // Setting down neighbour position coordinates [m]...
        float r_B_mag = resting[i_B].z;                                                          // Setting back neighbour position coordinates [m]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////// SYNERGIC MOLECULE: LINK VECTORS ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 l_R = p_R - p;                                                                              // Right neighbour link vector.
        float4 l_U = p_U - p;                                                                              // Up neighbour link vector.
        float4 l_F = p_F - p;                                                                              // Front neighbour link vector.
        float4 l_L = p_L - p;                                                                              // Left neighbour link vector.
        float4 l_D = p_D - p;                                                                              // Down neighbour link vector.
        float4 l_B = p_B - p;                                                                              // Back neighbour link vector.

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////// SYNERGIC MOLECULE: LINK LENGTH ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float l_R_mag = length(l_R);                                                                       // Right neighbour link length.
        float l_U_mag = length(l_U);                                                                       // Up neighbour link length.
        float l_F_mag = length(l_F);                                                                       // Front neighbour link length.
        float l_L_mag = length(l_L);                                                                       // Left neighbour link length.
        float l_D_mag = length(l_D);                                                                       // Down neighbour link length.
        float l_B_mag = length(l_B);                                                                       // Back neighbour link length.

        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT /////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 dp_R;                                                                                       // Right neighbour link displacement.
        float4 dp_U;                                                                                       // Up neighbour link displacement.
        float4 dp_F;                                                                                       // Front neighbour link displacement.
        float4 dp_L;                                                                                       // Left neighbour link displacement.
        float4 dp_D;                                                                                       // Down neighbour link displacement.
        float4 dp_B;                                                                                       // Back neighbour link displacement.

        if(l_R_mag > 0.0f)
        {
                dp_R = (l_R_mag - r_R_mag)*normalize(l_R);                                               // Right neighbour link displacement.
        }
        else
        {
                dp_R = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                                     // Right neighbour link displacement.
        }

        if(l_U_mag > 0.0f)
        {
                dp_U = (l_U_mag - r_U_mag)*normalize(l_U);                                        // Up neighbour link displacement.
        }
        else
        {
                dp_U = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                                     // Up neighbour link displacement.
        }

        if(l_F_mag > 0.0f)
        {
                dp_F = (l_F_mag - r_F_mag)*normalize(l_F);                                        // Front neighbour link displacement.
        }
        else
        {
                dp_F = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                                     // Front neighbour link displacement.
        }

        if(l_L_mag > 0.0f)
        {
                dp_L = (l_L_mag - r_L_mag)*normalize(l_L);                                        // Left neighbour link displacement.
        }
        else
        {
                dp_L = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                                     // Left neighbour link displacement.
        }

        if(l_D_mag > 0.0f)
        {
                dp_D = (l_D_mag - r_D_mag)*normalize(l_D);                                        // Down neighbour link displacement.
        }
        else
        {
                dp_D = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                                     // Down neighbour link displacement.
        }

        if(l_B_mag > 0.0f)
        {
                dp_B = (l_B_mag - r_B_mag)*normalize(l_B);                                        // Back neighbour link displacement.
        }
        else
        {
                dp_B = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                                     // Back neighbour link displacement.
        }

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR VELOCITIES ////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 v_R = velocity[i_R];                                                                        // Setting right neighbour velocity coordinates [m]...
        float4 v_U = velocity[i_U];                                                                        // Setting up neighbour velocity coordinates [m]...
        float4 v_F = velocity[i_F];                                                                        // Setting front neighbour velocity coordinates [m]...
        float4 v_L = velocity[i_L];                                                                        // Setting left neighbour velocity coordinates [m]...
        float4 v_D = velocity[i_D];                                                                        // Setting down neighbour velocity coordinates [m]...
        float4 v_B = velocity[i_B];                                                                        // Setting back neighbour velocity coordinates [m]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: NEIGHBOUR DISPATCHES ////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 dv_R = v_R - v;                                                                             // Right neighbour dispatch [m/s].
        float4 dv_U = v_U - v;                                                                             // Up neighbour dispatch [m/s].
        float4 dv_F = v_F - v;                                                                             // Front neighbour dispatch [m/s].
        float4 dv_L = v_L - v;                                                                             // Left neighbour dispatch [m/s].
        float4 dv_D = v_D - v;                                                                             // Down neighbour dispatch [m/s].
        float4 dv_B = v_B - v;                                                                             // Back neighbour dispatch [m/s].

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// SYNERGIC MOLECULE: LINK STIFFNESS ////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the stiffness of a dummy zero-length link must be 0.
        float C_R = stiffness[i_R];                                                                        // Setting right neighbour stiffness...
        float C_U = stiffness[i_U];                                                                        // Setting up neighbour stiffness...
        float C_F = stiffness[i_F];                                                                        // Setting front neighbour stiffness...
        float C_L = stiffness[i_L];                                                                        // Setting left neighbour stiffness...
        float C_D = stiffness[i_D];                                                                        // Setting down neighbour stiffness...
        float C_B = stiffness[i_B];                                                                        // Setting back neighbour stiffness...

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// SYNERGIC MOLECULE: LINK FRICTION /////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // NOTE: the friction of a dummy zero-length link must be 0.
        float B_R = friction[i_R];                                                                         // Setting right neighbour friction...
        float B_U = friction[i_U];                                                                         // Setting up neighbour friction...
        float B_F = friction[i_F];                                                                         // Setting front neighbour friction...
        float B_L = friction[i_L];                                                                         // Setting left neighbour friction...
        float B_D = friction[i_D];                                                                         // Setting down neighbour friction...
        float B_B = friction[i_B];                                                                         // Setting back neighbour friction...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: ELASTIC FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 Fe = 4.0f*(C_R*dp_R + C_U*dp_U + C_F*dp_F + C_L*dp_L + C_D*dp_D + C_B*dp_B);                     // Computing elastic force [N]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: VISCOUS FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // Elastic force applied to the particle:
        float4 Fv = 100.0f*(B_R*dv_R + B_U*dv_U + B_F*dv_F + B_L*dv_L + B_D*dv_D + B_B*dv_B);                    // Computing friction force [N]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////// SYNERGIC MOLECULE: GRAVITATIONAL FORCE ////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 Fg;

        float4 Fg_R;
        float4 Fg_U;
        float4 Fg_F;
        float4 Fg_L;
        float4 Fg_D;
        float4 Fg_B;

        if(l_R_mag > R0)
        {
                Fg_R = (m*m_R/pown(l_R_mag, 2))*normalize(l_R);
        }
        else
        {
                Fg_R = (m*m_R/pown(R0, 2))*normalize(l_R);
        }

        if(l_U_mag > R0)
        {
                Fg_U = (m*m_U/pown(l_U_mag, 2))*normalize(l_U);
        }
        else
        {
                Fg_U = (m*m_U/pown(R0, 2))*normalize(l_U);
        }

        if(l_F_mag > R0)
        {
                Fg_F = (m*m_F/pown(l_F_mag, 2))*normalize(l_F);
        }
        else
        {
                Fg_F = (m*m_F/pown(R0, 2))*normalize(l_F);
        }

        if(l_L_mag > R0)
        {
                Fg_L = (m*m_L/pown(l_L_mag, 2))*normalize(l_L);
        }
        else
        {
                Fg_L = (m*m_L/pown(R0, 2))*normalize(l_L);
        }

        if(l_D_mag > R0)
        {
                Fg_D = (m*m_D/pown(l_D_mag, 2))*normalize(l_D);
        }
        else
        {
                Fg_D = (m*m_D/pown(R0, 2))*normalize(l_D);
        }

        if(l_B_mag > R0)
        {
                Fg_B = (m*m_B/pown(l_B_mag, 2))*normalize(l_B);
        }
        else
        {
                Fg_B = (m*m_B/pown(R0, 2))*normalize(l_B);
        }

        Fg = 10.0f*(Fg_R + Fg_U + Fg_F + Fg_L + Fg_D + Fg_B);                                                      // Computing gravitational force [N]...

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////// SYNERGIC MOLECULE: TOTAL FORCE ////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 F    = fr*(Fe + Fv + Fg);                                                                   // Total force applied to the particle [N].

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////// VERLET INTEGRATION ///////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // COMPUTING ACCELERATION:
        a = F/m;                                                                                           // Computing acceleration [m/s^2]...

        // UPDATING POSITION:
        p += v*dt + a*dt*dt/2.0f;                                                                           // Updating position [m]...

        // FIXING PROJECTIVE SPACE:
        p.w = 1.0f;
        v.w = 1.0f;
        a.w = 1.0f;

        // UPDATING INTERMEDIATE KINEMATICS:
        position_int[gid] = p;                                                                             // Updating position (intermediate) [m]...
        velocity_int[gid] = v;                                                                             // Updating position (intermediate) [m/s]...
        acceleration_int[gid] = a;                                                                         // Updating position (intermediate) [m/s^2]...
}
