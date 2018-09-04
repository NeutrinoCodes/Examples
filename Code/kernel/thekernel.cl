/// @file

#define DT                        0.002f                                        // Time delta [s].
#define SAFEDIV(X, Y, EPSILON)    (X)/(Y + EPSILON)

void fix_projective_space(float4* vector)
{
  *vector *= (float4)(1.0f, 1.0f, 1.0f, 0.0f);                                  // Nullifying 4th projective component...
  barrier(CLK_GLOBAL_MEM_FENCE);

  *vector += (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                  // Setting 4th projective component to "1.0f"...
  barrier(CLK_GLOBAL_MEM_FENCE);

}

void assign_color(float4* color, float4* position)
{
  *color = fabs(*position);                                                     // Calculating |P|...
  barrier(CLK_GLOBAL_MEM_FENCE);

  *color *= (float4)(0.0f, 0.0f, 1.0f, 0.0f);                                   // Setting color.z = 0.5*|P|...
  barrier(CLK_GLOBAL_MEM_FENCE);

  *color += (float4)(0.4f, 0.0f, 0.0f, 1.0f);                                   // Adding colormap offset and adjusting alpha component...
  barrier(CLK_GLOBAL_MEM_FENCE);
}


void compute_link_displacements(float4 Pl_1, float4 Pl_2, float4 Pl_3, float4 Pl_4, float4 P,
                        float4 rl_1, float4 rl_2, float4 rl_3, float4 rl_4, float4 fr,
                        float4* Dl_1, float4* Dl_2, float4* Dl_3, float4* Dl_4)
{
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
  float4      epsilon = fr + (float4)(1.0f, 1.0f, 1.0f, 1.0f);                  // Safety margin for division.
  float4      sl_1 = SAFEDIV(ll_1 - rl_1, ll_1, epsilon);                       // 1st link strain.
  float4      sl_2 = SAFEDIV(ll_2 - rl_2, ll_2, epsilon);                       // 2nd link strain.
  float4      sl_3 = SAFEDIV(ll_3 - rl_3, ll_3, epsilon);                       // 3rd link strain.
  float4      sl_4 = SAFEDIV(ll_4 - rl_4, ll_4, epsilon);                       // 4th link strain.

  barrier(CLK_GLOBAL_MEM_FENCE);

  ////////////////////////////////////////////////////////////////////////////////
  //////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT ///////////////
  ////////////////////////////////////////////////////////////////////////////////
  *Dl_1 = sl_1*Ll_1;                                                            // 1st linked particle displacement.
  *Dl_2 = sl_2*Ll_2;                                                            // 2nd linked particle displacement.
  *Dl_3 = sl_3*Ll_3;                                                            // 3rd linked particle displacement.
  *Dl_4 = sl_4*Ll_4;                                                            // 4th linked particle displacement.
}


float4 compute_particle_force(float4 kl_1, float4 kl_2, float4 kl_3, float4 kl_4,
                              float4 Dl_1, float4 Dl_2, float4 Dl_3, float4 Dl_4,
                              float4 c, float4 V, float4 m, float4 G, float4 fr)
{
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

  return F;
}


__kernel void thekernel(__global float4*    position,
                        __global float4*    color,
                        __global float4*    position_old,
                        __global float4*    velocity,
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

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// GLOBAL INDEX /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned int gid = get_global_id(0);                                          // Setting global index "gid"...

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////// SYNERGIC MOLECULE: KINEMATIC VARIABLES /////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Po  = position_old[gid];                                          // Old particle position.
  float4      P   = position[gid];                                              // Current particle position.
  float4      V   = velocity[gid];                                              // Current particle velocity.
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
  float4      Pl_1 = position[il_1];                                           // 1st linked particle position.
  float4      Pl_2 = position[il_2];                                           // 2nd linked particle position.
  float4      Pl_3 = position[il_3];                                           // 3rd linked particle position.
  float4      Pl_4 = position[il_4];                                           // 4th linked particle position.

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

  float4      Dl_1;                                                             // 1st linked particle displacement.
  float4      Dl_2;
  float4      Dl_3;
  float4      Dl_4;

  compute_link_displacements(Pl_1, Pl_2, Pl_3, Pl_4, P, rl_1, rl_2, rl_3,
                                  rl_4, fr, &Dl_1, &Dl_2, &Dl_3, &Dl_4);

  barrier(CLK_GLOBAL_MEM_FENCE);

  float4 F = compute_particle_force(kl_1, kl_2, kl_3, kl_4, Dl_1, Dl_2, Dl_3, Dl_4,
                            c, V, m, G, fr);

  barrier(CLK_GLOBAL_MEM_FENCE);

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// VERLET INTEGRATION ///////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  // We define Vdt = (P - Po) instead of V = (P - Po)/DT because later we will
  // have to calculate: P = P + V*DT + A*DT^2.
  // In machine numbers, (X/DT)*DT is not exactly X due to a numerical
  // representation having a finite number of decimals.
  A = F/m;                                                                      // Calculating current acceleration...
  barrier(CLK_GLOBAL_MEM_FENCE);

  P += V*DT + A*DT*DT/2.0f;                                                           // Calculating and updating new position...

  barrier(CLK_GLOBAL_MEM_FENCE);

  // update positions in memory
  position[gid] = P;

  barrier(CLK_GLOBAL_MEM_FENCE);

  Pl_1 = position[il_1];                                           // 1st linked particle position.
  Pl_2 = position[il_2];                                           // 2nd linked particle position.
  Pl_3 = position[il_3];                                           // 3rd linked particle position.
  Pl_4 = position[il_4];                                           // 4th linked particle position.

  barrier(CLK_GLOBAL_MEM_FENCE);

  // save velocity at time t_n
  float4 Vn;
  Vn = V;
  barrier(CLK_GLOBAL_MEM_FENCE);

  // compute veelocity used for computation of acceleration at t_(n+1)
  V += A*DT;
  barrier(CLK_GLOBAL_MEM_FENCE);

  // compute new acceleration based on velocity estimate at t_(n+1)
  compute_link_displacements(Pl_1, Pl_2, Pl_3, Pl_4, P, rl_1, rl_2, rl_3,
                                  rl_4, fr, &Dl_1, &Dl_2, &Dl_3, &Dl_4);

  barrier(CLK_GLOBAL_MEM_FENCE);

  float4 Fnew = compute_particle_force(kl_1, kl_2, kl_3, kl_4, Dl_1, Dl_2, Dl_3, Dl_4,
                            c, V, m, G, fr);

  barrier(CLK_GLOBAL_MEM_FENCE);

  float4 Anew = Fnew/m;

  barrier(CLK_GLOBAL_MEM_FENCE);

  // predictor step: velocity at time t_(n+1) based on new forces
  V = Vn + DT*(A+Anew)/2.0f;

  barrier(CLK_GLOBAL_MEM_FENCE);

  // compute new acceleration based on predicted velocity at t_(n+1)
  Fnew = compute_particle_force(kl_1, kl_2, kl_3, kl_4, Dl_1, Dl_2, Dl_3, Dl_4,
                            c, V, m, G, fr);

  barrier(CLK_GLOBAL_MEM_FENCE);

  Anew = Fnew/m;

  barrier(CLK_GLOBAL_MEM_FENCE);

  // corrector step
  V = Vn + DT*(A+Anew)/2.0f;

  barrier(CLK_GLOBAL_MEM_FENCE);

  fix_projective_space(&Po);
  fix_projective_space(&P);
  fix_projective_space(&V);
  fix_projective_space(&A);
  barrier(CLK_GLOBAL_MEM_FENCE);

  assign_color(&col, &P);
  barrier(CLK_GLOBAL_MEM_FENCE);

  position_old[gid] = Po;                                                      // Updating OpenCL array...
  position[gid] = P;                                                           // Updating OpenCL array...
  velocity[gid] = V;                                                          // Updating OpenCL array...
  acceleration[gid] = A;                                                       // Updating OpenCL array...
  color[gid] = col;
  barrier(CLK_GLOBAL_MEM_FENCE);
}
