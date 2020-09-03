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
  float4        p                 = position[i];                                // Central node position.
  float4        v                 = velocity[i];                                // Central node velocity.
  float4        a                 = acceleration[i];                            // Central node acceleration.
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

  // APPLYING FREEDOM CONSTRAINTS:
  if (fr == 0)
  {
    v = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                       // Constraining velocity...
    a = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                       // Constraining acceleration...
  }

  // COMPUTING NEW POSITION:
  p_new = p + v*dt + 0.5f*a*dt*dt;                                              // Computing Taylor's approximation...

  // FIXING PROJECTIVE SPACE:
  p_new.w = 1.0f;                                                               // Adjusting projective space...
  
  // UPDATING INTERMEDIATE POSITION:
  position_int[i] = p_new;                                                      // Updating position...
  velocity_int[i] = v;                                                          // Updating position...
  acceleration_int[i] = a;                                                      // Updating position...
}
