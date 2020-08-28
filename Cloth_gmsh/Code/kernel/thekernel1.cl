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
  //////////////////////////////////// INDEXES ///////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned long i = get_global_id(0);                                           // Global index [#].
  unsigned long j;
  unsigned long k;
  unsigned long n = offset[i];                                                  // Neighbour node index offset.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// CELL: KINEMATIC VARIABLES ///////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4        c = color[i];                                                   // Central node color.
  float4        p = position[i];                                                // Central node position.
  float4        v = velocity[i];                                                // Central node velocity.
  float4        a = acceleration[i];                                            // Central node acceleration.
  float4        p_n;                                                            // Neighbour node position.
  
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// CELL: DYNAMIC VARIABLES /////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4        m   = node_mass[i];                                             // Node mass.
  float4        g   = gravity[i];                                               // Node gravity field.
  float4        B   = friction[0];                                              // Node friction.
  float4        fr  = freedom[i];                                               // Node freedom flag.
  float4        Fe  = (0.0f, 0.0f, 0.0f, 1.0f);                                 // Node elastic force.  
  float4        Fv  = (0.0f, 0.0f, 0.0f, 1.0f);                                 // Node viscous force.
  float4        Fg  = (0.0f, 0.0f, -g, 1.0f);                                   // Node gravitational force. 
  float4        F   = (0.0f, 0.0f, 0.0f, 1.0f);                                 // Node total force.
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

    Fe += neighbour_stiffness*neighbour_displacement;                           // Accumulating elastic force on central node for each neighbour...
  }

  Fv = -B*v;                                                                    // Calculating node viscous force...

  if((m > 0.0f) && (length(p) > R0))
  {
    F  = fr*(Fe + Fv + Fg);                                                     // Total force applied to the particle [N]...
    node_acceleration  = F/m;                                                   // Computing acceleration [m/s^2]...
  }
  else
  {
    a = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                       // Nullifying force [m/s^2]...
    v = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                       // Nullifying momentum [N]...
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
  p_int[gid] = p;                                                               // Updating position (intermediate) [m]...
  v_int[gid] = v;                                                               // Updating position (intermediate) [m/s]...
  a_int[gid] = a;                                                               // Updating position (intermediate) [m/s^2]...
}
