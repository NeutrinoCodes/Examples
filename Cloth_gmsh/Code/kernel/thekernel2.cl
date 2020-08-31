/// @file

__kernel void thekernel(__global float4*    color,                              // Color.
                        __global float4*    position,                           // Position.
                        __global float4*    position_int,                       // Position (intermediate).
                        __global float4*    velocity,                           // Velocity.
                        __global float4*    velocity_int,                       // Velocity (intermediate).
                        __global float4*    acceleration,                       // Acceleration.
                        __global float4*    acceleration_int,                   // Acceleration (intermediate).
                        __global float4*    gravity,                            // Gravity.
                        __global float*     stiffness,                          // Stiffness.
                        __global float*     resting,                            // Resting distance.
                        __global float*     friction,                           // Friction.
                        __global float*     mass,                               // Mass.
                        __global long*      nearest,                            // Neighbour.
                        __global long*      offset,                             // Offset.
                        __global float*     freedom,                            // Freedom flag.
                        __global float*     dt_simulation)                      // Simulation time step.
{
  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// INDEXES ///////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned long i = get_global_id(0);                                           // Global index [#].
  unsigned long j = 0;                                                          // Neighbour stride index.
  unsigned long j_min = 0;                                                      // Neighbour stride minimun index.
  unsigned long j_max = offset[i];                                              // Neighbour stride maximum index.
  unsigned long k = 0;                                                          // Neighbour tuple index.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// CELL VARIABLES //////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4        c = color[i];                                                   // Central node color.
  float4        p = position_int[i];                                            // Central node position.
  float4        v = velocity_int[i];                                            // Central node velocity.
  float4        v_n;                                                            // Central node velocity backup.
  float4        a = acceleration_int[i];                                        // Central node acceleration.
  float4        a_new;                                                          // Central node new acceleration.
  float         m   = mass[i];                                                  // Central node mass.
  float4        g   = gravity[0];                                               // Central node gravity field.
  float         B   = friction[0];                                              // Central node friction.
  float         fr  = freedom[i];                                               // Central node freedom flag.
  float4        Fe  = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Central node elastic force.  
  float4        Fv  = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Central node viscous force.
  float4        Fg  = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Central node gravitational force. 
  float4        F_new   = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                     // Central node new total force.
  float4        p_n = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Neighbour node position.
  float4        link_n = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                      // Neighbour link.
  float4        disp_n   = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                    // Neighbour displacement.
  float         R_n = 0.0f;                                                     // Neighbour link resting length.
  float         stiff_n = 0.0f;                                                 // Neighbour link stiffness.
  float         strain_n = 0.0f;                                                // Neighbour link strain.
  float         L_n = 0.0f;                                                     // Neighbour link length.
  float         dt  = dt_simulation[0];                                         // Simulation time step [s].

  // VELOCITY BACKUP (@ t_n):
  v_n = v;                                                                      // Velocity backup...

  // COMPUTING VELOCITY (for acceleration computation @ t_(n+1)):
  v += a*dt;                                                                    // Velocity estimation for acceleration computation @ t_(n+1)...

  // COMPUTING ACCELERATION:
  if (i == 0)
  {
    j_min = 0;
  }
  else
  {
    j_min = offset[i - 1];
  }

  for (j = j_min; j < j_max; j++)
  {
    k = nearest[j];                                                             // Computing neighbour index...
    p_n = position[k];                                                          // Getting neighbour position...
    link_n = p_n - p;                                                           // Getting neighbour link vector...
    R_n = resting[j];                                                           // Getting neighbour link resting length...
    stiff_n = stiffness[j];                                                     // Getting neighbour link stiffness...
    L_n = length(link_n);                                                       // Computing neighbour link length...
    strain_n = L_n - R_n;                                                       // Computing neighbour link strain...
    disp_n = strain_n*normalize(link_n);                                        // Computing neighbour link displacement...
    Fe += stiff_n*disp_n;                                                       // Building up elastic force on central node...
  }

  Fg = m*g;                                                                     // Computing node gravitational force...
  Fv = -B*v;                                                                    // Computing node viscous force...
  F_new  = fr*(Fe + Fv + Fg);                                                   // Computing fotal node force...
  a_new  = F_new/m;                                                             // Computing acceleration...

  // PREDICTOR (velocity @ t_(n+1) based on new acceleration):
  v = v_n + dt*(a + a_new)/2.0f;                                                // Computing velocity [m/s]...
  Fv = -B*v;                                                                    // Computing node viscous force...
  F_new  = fr*(Fe + Fv + Fg);                                                   // Computing fotal node force...
  a_new  = F_new/m;                                                             // Computing acceleration...

  // CORRECTOR (velocity @ t_(n+1) based on new acceleration):
  v = v_n + dt*(a + a_new)/2.0f;                                                // Computing velocity [m/s]...
  
  // FIXING PROJECTIVE SPACE:
  p.w = 1.0f;                                                                   // Adjusting projective space...
  v.w = 1.0f;                                                                   // Adjusting projective space...
  a.w = 1.0f;                                                                   // Adjusting projective space...

  // ASSIGNING COLOR:
  

  // UPDATING KINEMATICS:
  color[i] = c;                                                                 // Updating color [#]...
  position[i] = p;                                                              // Updating position [m]...
  velocity[i] = v;                                                              // Updating velocity [m/s]...
  acceleration[i] = a;                                                          // Updating acceleration [m/s^2]...
}
