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
  unsigned int j = 0;                                                           // Neighbour stride index.
  unsigned int j_min = 0;                                                       // Neighbour stride minimun index.
  unsigned int j_max = offset[i];                                               // Neighbour stride maximum index.
  unsigned int k = 0;                                                           // Neighbour tuple index.
  unsigned int n = central[i];                                                  // Node index.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// CELL VARIABLES //////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4        c                 = color[n];                                   // Central node color.
  float4        v                 = velocity[n];                                // Central node velocity.
  float4        a                 = acceleration[n];                            // Central node acceleration.
  float4        p_int             = position_int[n];                            // Central node position (intermediate).
  float4        v_int             = velocity_int[n];                            // Central node velocity (intermediate).
  float4        p_new             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node position (new).
  float4        v_new             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node velocity (new).
  float4        a_new             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node acceleration (new).
  float4        v_est             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node velocity (estimation).
  float4        a_est             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node acceleration (estimation).
  float         m                 = mass[n];                                    // Central node mass.
  float4        g                 = gravity[0];                                 // Central node gravity field.
  float         B                 = friction[0];                                // Central node friction.
  float         fr                = freedom[n];                                 // Central node freedom flag.
  float4        Fe                = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node elastic force.  
  float4        Fv                = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node viscous force.
  float4        Fv_est            = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node viscous force (estimation).
  float4        Fg                = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node gravitational force. 
  float4        F                 = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node total force.
  float4        F_new             = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Central node total force (new).
  float4        neighbour         = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Neighbour node position.
  float4        link              = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Neighbour link.
  float4        D                 = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Neighbour displacement.
  float         R                 = 0.0f;                                       // Neighbour link resting length.
  float         K                 = 0.0f;                                       // Neighbour link stiffness.
  float         S                 = 0.0f;                                       // Neighbour link strain.
  float         L                 = 0.0f;                                       // Neighbour link length.
  float         dt                = dt_simulation[0];                           // Simulation time step [s].

  float         K_gauss           = 0.0f;                                       // Gaussian curvature.
  float         K_mean            = 0.0f;                                       // Mean curvature.
  float         area              = 0.0f;                                       // Laplace-Beltrami area.
  float         theta             = 0.0f;                                       // Laplace-Beltrami angle.
  float3        p_A               = (float3)(0.0f, 0.0f, 0.0f);
  float3        p_B               = (float3)(0.0f, 0.0f, 0.0f);
  float3        p_C               = (float3)(0.0f, 0.0f, 0.0f);
  float3        link_A            = (float3)(0.0f, 0.0f, 0.0f);                 // Laplace_Beltrami 1st edge backup.
  float3        link_B            = (float3)(0.0f, 0.0f, 0.0f);                 // Laplace-Beltrami previous edge.
  float3        link_C            = (float3)(0.0f, 0.0f, 0.0f);                 // Laplace-Beltrami current edge.
  
  // COMPUTING STRIDE MINIMUM INDEX:
  if (i == 0)
  {
    j_min = 0;                                                                  // Setting stride minimum (first stride)...
  }
  else
  {
    j_min = offset[i - 1];                                                      // Setting stride minimum (all others)...
  }

  theta = 0.0f;

  // COMPUTING ELASTIC FORCE:
  for (j = j_min; j < j_max; j++)
  {
    k = nearest[j];                                                             // Computing neighbour index...
    neighbour = position_int[k];                                                // Getting neighbour position...
    link = neighbour - p_int;                                                   // Getting neighbour link vector...
    R = resting[j];                                                             // Getting neighbour link resting length...
    K = stiffness[j];                                                           // Getting neighbour link stiffness...
    L = length(link);                                                           // Computing neighbour link length...
    S = L - R;                                                                  // Computing neighbour link strain...
    D = S*normalize(link);                                                      // Computing neighbour link displacement...
    Fe += K*D;                                                                  // Building up elastic force on central node...
    
    p_B = p_C;
    p_C = neighbour.xyz;
    link_B = link_C;
    link_C = link.xyz;
    
    if (j == j_min)
    {
      p_A = neighbour.xyz;
      link_A = link.xyz;
    }
    else
    {
      K_mean += dot((normalize(link_C) - normalize(link_B)),(p_C - p_B))/
                dot((p_C - p_B),(p_C - p_B));
      theta += fabs(acos(dot(normalize(link_B), normalize(link_C))));
      area += length(cross(link_B, link_C));
    }
  }

  p_B = p_C;
  p_C = p_A;
  link_B = link_C;
  link_C = link_A;
  K_mean += dot((normalize(link_C) - normalize(link_B)),(p_C - p_B))/
            dot((p_C - p_B),(p_C - p_B));
  K_mean = K_mean/(j_max - j_min);     
  theta += fabs(acos(dot(normalize(link_B), normalize(link_C))));
  area += length(cross(link_B, link_C));
  K_gauss = 3.0f*(2.0f*M_PI - theta)/area;
  
  // COMPUTING TOTAL FORCE:
  Fg = m*g;                                                                     // Computing node gravitational force...
  Fv = -B*v_int;                                                                // Computing node viscous force...
  F = Fg + Fe + Fv;                                                             // Computing total node force...
  
  // COMPUTING NEW ACCELERATION ESTIMATION:
  a_est  = F/m;                                                                 // Computing acceleration...

  // COMPUTING NEW VELOCITY ESTIMATION:
  v_est = v + 0.5f*(a + a_est)*dt;                                              // Computing velocity...

  // COMPUTING NEW VISCOUS FORCE ESTIMATION:
  Fv_est = -B*v_est;                                                            // Computing node viscous force...

  // COMPUTING NEW TOTAL FORCE:
  F_new = Fg + Fe + Fv_est;                                                     // Computing total node force...

  // COMPUTING NEW ACCELERATION:
  a_new = F_new/m;                                                              // Computing acceleration...

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
  position[n] = p_int;                                                          // Updating position [m]...
  velocity[n] = v_new;                                                          // Updating velocity [m/s]...
  acceleration[n] = a_new;                                                      // Updating acceleration [m/s^2]...

  c.x = 0.1f*(50 - K_mean);
  c.y = 0.4f - 0.1f*(50 - K_mean);
  c.z = 0.2f;
  color[n] = c;
}
