/// @file

#define DT                        0.001f                                        // Time delta [s].
#define SAFEDIV(X, Y, EPSILON)    (X)/(Y + EPSILON)

float4 fix_projective_space(float4 vector)
{
  vector *= float4(1.0f, 1.0f, 1.0f, 0.0f);                                     // Nullifying 4th projective component...
  barrier(CLK_GLOBAL_MEM_FENCE);

  vector += float4(0.0f, 0.0f, 0.0f, 1.0f);                                     // Setting 4th projective component to "1.0f"...
  barrier(CLK_GLOBAL_MEM_FENCE);

  return vector;
}

float4 assign_color(float4 color, float4 position)
{
  color = fabs(P);                                                              // Calculating |P|...
  barrier(CLK_GLOBAL_MEM_FENCE);

  color *= float4(0.0f, 0.0f, 0.5f, 0.0f);                                      // Setting color.z = 0.5*|P|...
  barrier(CLK_GLOBAL_MEM_FENCE);

  color += float4(0.0f, 0.2f, 0.3f, 1.0f);                                      // Adding colormap offset and adjusting alpha component...
  barrier(CLK_GLOBAL_MEM_FENCE);
}

__kernel void thekernel(__global float4*    position,
                        __global float4*    color,
                        __global float4*    position_old,
                        __global float4*    velocity_by_dt,
                        __global float4*    acceleration,
                        __global float4*    gravity,
                        __global float4*    stiffness,
                        __global float4*    resting,
                        __global float4*    friction,
                        __global float4*    mass,
                        __global int*       index_friend_1,                     // Indexes of "#1 friend" particles.
                        __global int*       index_friend_2,                     // Indexes of "#2 friend" particles.
                        __global int*       index_friend_3,                     // Indexes of "#3 friend" particles.
                        __global int*       index_friend_4,                     // Indexes of "#4 friend" particles.
                        __global float4*    freedom)
{
  float4      epsilon;

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// GLOBAL INDEX /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned int gid = get_global_id(0);                                          // Setting global index "gid"...

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Po  = position_old[gid];                                          // Old particle position.
  float4      P   = position[gid];                                              // Current particle position.
  float4      Vdt = velocity_by_dt[gid];                                        // Current particle velocity*dt.
  float4      A   = acceleration[gid];                                          // Current particle acceleration.

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: DYNAMIC VARIABLES ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      m   = mass[gid];                                                  // Current particle mass.
  float4      G   = gravity[gid];                                               // Current particle gravity field.
  float4      c   = friction[gid];                                              // Current particle friction.
  float4      fr  = freedom[gid];                                               //
  float4      col = color[gid];                                                 // Current particle color.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK INDEXES /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: 1. the index of a non-existing particle friend must be set to the index of the particle.
  int         il_1 = index_friend_1[gid];                                       // Setting indexes of 1st linked particle...
  int         il_2 = index_friend_2[gid];                                       // Setting indexes of 2nd linked particle...
  int         il_3 = index_friend_3[gid];                                       // Setting indexes of 3rd linked particle...
  int         il_4 = index_friend_4[gid];                                       // Setting indexes of 4th linked particle...

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////// SYNERGIC MOLECULE: LINKED PARTICLE POSITIONS /////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Pl_1 = positions[il_1];                                           // 1st linked particle position.
  float4      Pl_2 = positions[il_2];                                           // 2nd linked particle position.
  float4      Pl_3 = positions[il_3];                                           // 3rd linked particle position.
  float4      Pl_4 = positions[il_4];                                           // 4th linked particle position.

  ////////////////////////////////////////////////////////////////////////////////
  //////////////// SYNERGIC MOLECULE: LINK RESTING DISTANCES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      rl_1 = resting[il_1];                                             // 1st linked particle resting distance.
  float4      rl_2 = resting[il_2];                                             // 2nd linked particle resting distance.
  float4      rl_3 = resting[il_3];                                             // 3rd linked particle resting distance.
  float4      rl_4 = resting[il_4];                                             // 4th linked particle resting distance.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINK STIFFNESS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  // NOTE: the stiffness of a non-existing link must reset to 0.
  float4      kl_1 = stiffness[il_1];                                           // 1st link stiffness.
  float4      kl_2 = stiffness[il_2];                                           // 2nd link stiffness.
  float4      kl_3 = stiffness[il_3];                                           // 3rd link stiffness.
  float4      kl_4 = stiffness[il_4];                                           // 4th link stiffness.

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////// SYNERGIC MOLECULE: LINKED PARTICLE VECTOR ///////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Ll_1 = Pl_1 - P;                                                  // 1st linked particle vector.
  float4      Ll_2 = Pl_2 - P;                                                  // 2nd linked particle vector.
  float4      Ll_3 = Pl_3 - P;                                                  // 3rd linked particle vector.
  float4      Ll_4 = Pl_4 - P;                                                  // 4th linked particle vector.

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: LINK LENGTH ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      ll_1 = length(Ll_1);                                              // 1st link length.
  float4      ll_2 = length(Ll_2);                                              // 2nd link length.
  float4      ll_3 = length(Ll_3);                                              // 3rd link length.
  float4      ll_4 = length(Ll_4);                                              // 4th link length.

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: LINK STRAIN ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
           epsilon = fr + (float4)(1.0f, 1.0f, 1.0f, 1.0f);                     // Safety margin for division.
  float4      sl_1 = SAFEDIV(ll_1 - rl_1, ll_1, epsilon);                       // 1st link strain.
  float4      sl_2 = SAFEDIV(ll_2 - rl_2, ll_2, epsilon);                       // 2nd link strain.
  float4      sl_3 = SAFEDIV(ll_3 - rl_3, ll_3, epsilon);                       // 3rd link strain.
  float4      sl_4 = SAFEDIV(ll_4 - rl_4, ll_4, epsilon);                       // 4th link strain.

  //col = fabs(sR + sU + sL + sD)/4;
  //col.r = 0.2f;

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  //////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT ///////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Dl_1 = sl_1*Ll_1;                                                 // 1st linked particle displacement.
  float4      Dl_2 = sl_2*Ll_2;                                                 // 2nd linked particle displacement.
  float4      Dl_3 = sl_3*Ll_3;                                                 // 3rd linked particle displacement.
  float4      Dl_4 = sl_4*Ll_4;                                                 // 4th linked particle displacement.

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// SYNERGIC MOLECULE: ELASTIC FORCE //////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Fe   = (kl_1*Dl_1 + kl_2*Dl_2 + kl_3*Dl_3 + kl_4*Dl_4);           // Elastic force applied to the particle.

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// SYNERGIC MOLECULE: VISCOUS FORCE //////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Fv   = -c*V;                                                      // Viscous force applied to the particle.

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////// SYNERGIC MOLECULE: GRAVITATIONAL FORCE ///////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Fg   = m*G;                                                       // Gravitational force applied to the particle.

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: TOTAL FORCE ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      F    = fr*(Fe + Fv + Fg);                                         // Total force applied to the particle.

  barrier(CLK_GLOBAL_MEM_FENCE);

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// VERLET INTEGRATION ///////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  // We define Vdt = (P - Po) instead of V = (P - Po)/DT because later we will
  // have to calculate: P = P + V*DT + A*DT^2.
  // In machine numbers, (X/DT)*DT is not exactly X due to a numerical
  // representation having a finite number of decimals.
  Vdt = (P - Po);                                                               // Calculating current velocity*dt...
  A = F/m;                                                                      // Calculating current acceleration...
  Po = P;                                                                       // Updating old position...
  barrier(CLK_GLOBAL_MEM_FENCE);

  P += Vdt + A*DT*DT;                                                           // Calculating and updating new position...
  barrier(CLK_GLOBAL_MEM_FENCE);

  fix_projective_space(Po);
  fix_projective_space(P);
  fix_projective_space(V);
  fix_projective_space(A);
  barrier(CLK_GLOBAL_MEM_FENCE);

  assign_color(col, P);
  barrier(CLK_GLOBAL_MEM_FENCE);

  Positions_old[iPC] = Po;                                                      // Updating OpenCL array...
  Positions[iPC] = P;                                                           // Updating OpenCL array...
  Velocities[iPC] = V;                                                          // Updating OpenCL array...
  Accelerations[iPC] = A;                                                       // Updating OpenCL array...
  Colors[iPC] = col;
  barrier(CLK_GLOBAL_MEM_FENCE);
}
