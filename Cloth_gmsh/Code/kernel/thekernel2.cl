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
                        __global long*      freedom,                            // Freedom flag.
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
  float4        c                 = color[i];                                   // Central node color.
  float4        p                 = position_int[i];                            // Central node position.
  float4        v                 = velocity_int[i];                            // Central node velocity.
  float4        a                 = acceleration_int[i];                        // Central node acceleration.
  float4        p_new             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node position.
  float4        v_new             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node velocity.
  float4        a_new             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node acceleration.
  float         m                 = mass[i];                                    // Central node mass.
  float4        g                 = gravity[0];                                 // Central node gravity field.
  float         B                 = friction[0];                                // Central node friction.
  float         fr                = freedom[i];                                 // Central node freedom flag.
  float4        Fe                = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node elastic force.  
  float4        Fv                = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node viscous force.
  float4        Fg                = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node gravitational force. 
  float4        F                 = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node total force.
  float4        neighbour         = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Neighbour node position.
  float4        link              = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Neighbour link.
  float4        D                 = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Neighbour displacement.
  float         R                 = 0.0f;                                       // Neighbour link resting length.
  float         K                 = 0.0f;                                       // Neighbour link stiffness.
  float         S                 = 0.0f;                                       // Neighbour link strain.
  float         L                 = 0.0f;                                       // Neighbour link length.
  float         dt                = dt_simulation[0];                           // Simulation time step [s].
  
  // COMPUTING j_min INDEX:
  if (i == 0)
  {
    j_min = 0;
  }
  else
  {
    j_min = offset[i - 1];
  }

  // COMPUTING ELASTIC FORCE:
  for (j = j_min; j < j_max; j++)
  {
    k = nearest[j];                                                             // Computing neighbour index...
    neighbour = position_int[k];                                                // Getting neighbour position...
    link = neighbour - p;                                                       // Getting neighbour link vector...
    R = resting[j];                                                             // Getting neighbour link resting length...
    K = stiffness[j];                                                           // Getting neighbour link stiffness...
    L = length(link);                                                           // Computing neighbour link length...
    S = L - R;                                                                  // Computing neighbour link strain...
    D = S*normalize(link);                                                      // Computing neighbour link displacement...
    Fe += K*D;                                                                  // Building up elastic force on central node...
  }

  // COMPUTING TOTAL FORCE:
  Fg = m*g;                                                                     // Computing node gravitational force...
  Fv = -B*v;                                                                    // Computing node viscous force...
  F = Fg + Fe;                                                                  // Computing fotal node force...
  
  // COMPUTING NEW ACCELERATION:
  a_new  = F/m;                                                                 // Computing acceleration...

  // APPLYING FREEDOM CONSTRAINTS:
  if (fr == 0)
  {
    a_new = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                   // Constraining acceleration...
  }

  // COMPUTING NEW VELOCITY:
  v_new = v + 0.5f*(a + a_new)*dt;                                              // Computing velocity...

  // APPLYING FREEDOM CONSTRAINTS:
  if (fr == 0)
  {
    v_new = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                   // Constraining velocity...
  }

  // FIXING PROJECTIVE SPACE:
  v_new.w = 1.0f;                                                               // Adjusting projective space...
  a_new.w = 1.0f;                                                               // Adjusting projective space...

  // UPDATING KINEMATICS:
  position[i] = p;                                                              // Updating position [m]...
  velocity[i] = v_new;                                                          // Updating velocity [m/s]...
  acceleration[i] = a_new;                                                      // Updating acceleration [m/s^2]...
}
