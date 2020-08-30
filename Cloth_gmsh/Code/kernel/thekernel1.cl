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
  float4        c        = color[i];                                            // Central node color.
  float4        p        = position[i];                                         // Central node position.
  float4        v        = velocity[i];                                         // Central node velocity.
  float4        a        = acceleration[i];                                     // Central node acceleration.
  float         m        = mass[i];                                             // Central node mass.
  float4        g        = gravity[0];                                          // Central node gravity field.
  float         B        = friction[0];                                         // Central node friction.
  float         fr       = freedom[i];                                          // Central node freedom flag.
  float4        Fe       = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                    // Central node elastic force.  
  float4        Fv       = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                    // Central node viscous force.
  float4        Fg       = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                    // Central node gravitational force. 
  float4        F        = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                    // Central node total force.
  float4        p_n      = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                    // Neighbour node position.
  float4        link_n   = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                    // Neighbour link.
  float4        disp_n   = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                    // Neighbour displacement.
  float         R_n      = 0.0f;                                                // Neighbour link resting length.
  float         stiff_n  = 0.0f;                                                // Neighbour link stiffness.
  float         strain_n = 0.0f;                                                // Neighbour link strain.
  float         L_n      = 0.0f;                                                // Neighbour link length.
  float         dt       = dt_simulation[0];                                    // Simulation time step [s].

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
    //printf("strain = %f\n", length(position[11805] - position[0]) - resting[11805]);
    if(L_n > 0.0f)
    {
      disp_n = strain_n*normalize(link_n);                                      // Computing neighbour link displacement...
    }
    else
    {
      disp_n = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                // Computing neighbour link displacement...
    }

    Fe += stiff_n*disp_n;                                                       // Building up elastic force on central node...
  }

  Fg = m*g;                                                                     // Computing node gravitational force...
  Fv = -B*v;                                                                    // Computing node viscous force...
  F  = fr*(Fg + Fe + Fv);                                                       // Computing fotal node force...
  a  = F/m;                                                                     // Computing acceleration...
  
  // UPDATING POSITION:
  p += v*dt + a*dt*dt/2.0f;                                                     // Updating position [m]...

  // FIXING PROJECTIVE SPACE:
  p.w = 1.0f;                                                                   // Adjusting projective space...
  v.w = 1.0f;                                                                   // Adjusting projective space...
  a.w = 1.0f;                                                                   // Adjusting projective space...

  // UPDATING INTERMEDIATE KINEMATICS:
  position[i] = p;                                                          // Updating position (intermediate)...
  velocity[i] = v;                                                          // Updating position (intermediate)...
  acceleration[i] = a;                                                      // Updating position (intermediate)...
}
