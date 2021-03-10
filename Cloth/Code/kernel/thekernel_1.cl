/// @file

__kernel void thekernel(__global float4*    color,                              // Color.
                        __global float4*    position,                           // Position.
                        __global float4*    position_int,                       // Position (intermediate).
                        __global float4*    velocity,                           // Velocity.
                        __global float4*    velocity_int,                       // Velocity (intermediate).
                        __global float4*    acceleration,                       // Acceleration.
                        __global float4*    gravity,                            // Gravity.
                        __global float*     stiffness,                          // Stiffness.
                        __global float*     resting,                            // Resting distance.
                        __global float*     friction,                           // Friction.
                        __global float*     mass,                               // Mass.
                        __global int*       central,                            // Node.
                        __global int*       nearest,                            // Neighbour.
                        __global int*       offset,                             // Offset.
                        __global int*       freedom,                            // Freedom flag.
                        __global float*     dt_simulation)                      // Simulation time step.
{
  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// INDEXES ///////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned int i = get_global_id(0);                                            // Global index [#].
  
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// CELL VARIABLES //////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4        p                 = position[i];                                // Central node position.
  float4        v                 = velocity[i];                                // Central node velocity.
  float4        a                 = acceleration[i];                            // Central node acceleration.
  float4        p_new             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node position. 
  float         fr                = freedom[i];                                 // Central node freedom flag.
  float         dt                = dt_simulation[0];                           // Simulation time step [s].

  // APPLYING FREEDOM CONSTRAINTS:
  if (fr == 0)
  {
    v = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                       // Constraining velocity...
    a = (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                       // Constraining acceleration...
  }
  
  // COMPUTING NEW POSITION:
  p_new = p + v*dt + 0.5f*a*dt*dt;                                              // Computing Taylor's approximation...
  
  // UPDATING INTERMEDIATE POSITION:
  position_int[i] = p_new;                                                      // Updating intermediate position...
  velocity_int[i] = v + a*dt;                                                   // Updating intermediate velocity...

  // FIXING PROJECTIVE SPACE:
  position_int[i].w = 1.0f;                                                     // Adjusting projective space...
  velocity_int[i].w = 1.0f;                                                     // Adjusting projective space...
}
