/// @file

__kernel void thekernel(__global float4*    color,                              // Color.
                        __global float4*    position,                           // Position.
                        __global float4*    position_int,                       // Position (intermediate).
                        __global float4*    velocity,                           // Velocity.
                        __global float4*    velocity_int,                       // Velocity (intermediate).
                        __global float4*    acceleration,                       // Acceleration.
                        __global float4*    acceleration_int,                   // Acceleration (intermediate).
                        __global float4*    gravity,                            // Gravity.
                        __global float4*    stiffness,                          // Stiffness.
                        __global float4*    resting,                            // Resting distance.
                        __global float4*    friction,                           // Friction.
                        __global float4*    mass,                               // Mass.
                        __global long*      neighbour,                          // Neighbour.
                        __global long*      offset,                             // Offset.
                        __global float4*    freedom,                            // Freedom flag.
                        __global float*     dt_simulation)                      // Simulation time step.
{
  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// INDEXES ///////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned long i = get_global_id(0);                                           // Global index [#].
  unsigned long j = 0;                                                          // Neighbour stride index.
  unsigned long k = 0;                                                          // Neighbour tuple index.
  unsigned long n = offset[i];                                                  // Neighbour node index offset.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// CELL: KINEMATIC VARIABLES ///////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4        c = color[i];                                                   // Central node color.
  float4        p = position[i];                                                // Central node position.
  float4        v = velocity[i];                                                // Central node velocity.
  float4        a = acceleration[i];                                            // Central node acceleration.
  float4        p_n = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Neighbour node position.
  
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// CELL: DYNAMIC VARIABLES /////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4        m   = node_mass[i];                                             // Node mass.
  float4        g   = gravity[0];                                               // Node gravity field.
  float4        B   = friction[0];                                              // Node friction.
  float4        fr  = freedom[i];                                               // Node freedom flag.
  float4        Fe  = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Node elastic force.  
  float4        Fv  = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Node viscous force.
  float4        Fg  = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Node gravitational force. 
  float4        F   = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                         // Node total force.
  float         dt  = dt_simulation[0];                                         // Simulation time step [s].

  for (j = 0; j < offset; j++)
  {
    k = neighbour[n + j];                                                       // Calculating neighbour index...
    p_n = position[k];                                                          // Getting neighbour position...
    link_n = p_n - p;                                                           // Getting neighbour link vector...
    R_n = resting[k];                                                           // Getting neighbour link resting length...
    stiff_n = stiffness[k];                                                     // Getting neighbour link stiffness...
    L_n = length(link_n);                                                       // Calculating neighbour link length...
    strain_n = L_n - R_n;                                                       // Calculating neighbour link strain...

    if(L_n > 0.0f)
    {
      disp_n = strain_n*normalize(link_n);                                      // Calculating neighbour link displacement...
    }
    else
    {
      disp_n = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                // Calculating neighbour link displacement...
    }

    Fe += stiff_n*disp_n;                                                       // Building up elastic force on central node...
  }

  Fv = -B*v;                                                                    // Calculating node viscous force...
  Fg = m*g

  if((m > 0.0f) && (length(p) > R0))
  {
    F  = fr*(Fe + Fv + Fg);                                                     // Total force applied to the particle...
    node_acceleration  = F/m;                                                   // Computing acceleration...
  }
  else
  {
    a = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                       // Nullifying force...
    v = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                       // Nullifying momentum...
  }

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// VERLET INTEGRATION /////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // UPDATING POSITION:
  p += v*dt + a*dt*dt/2.0f;                                                     // Updating position [m]...

  // FIXING PROJECTIVE SPACE:
  p.w = 1.0f;                                                                   // Adjusting projective space...
  v.w = 1.0f;                                                                   // Adjusting projective space...
  a.w = 1.0f;                                                                   // Adjusting projective space...

  // UPDATING INTERMEDIATE KINEMATICS:
  p_int[i] = p;                                                                 // Updating position (intermediate)...
  v_int[i] = v;                                                                 // Updating position (intermediate)...
  a_int[i] = a;                                                                 // Updating position (intermediate)...
}
