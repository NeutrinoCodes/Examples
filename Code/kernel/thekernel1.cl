/// @file

#define DT                        0.0005f                                        // Time delta [s].
#define SAFEDIV(X, Y, EPSILON)    (X)/(Y + EPSILON)
#define RMIN                      0.4f                                          // Offset red channel for colormap
#define RMAX                      0.5f                                          // Maximum red channel for colormap
#define BMIN                      0.0f                                          // Offset blue channel for colormap
#define BMAX                      1.0f                                          // Maximum blue channel for colormap
#define SCALE                     1.5f                                          // Scale factor for plot

void fix_projective_space(float4* vector)
{
  *vector *= (float4)(1.0f, 1.0f, 1.0f, 0.0f);                                  // Nullifying 4th projective component...

  *vector += (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                  // Setting 4th projective component to "1.0f"...
}

/** Assign color based on a custom colormap.
*/
void assign_color(float4* color, float4* position)
{
  // Taking the component-wise absolute value of the position vector...
  float4 p = fabs(*position)*SCALE;

  // Extracting the z-component of the displacement...
  p *= (float4)(0.0f, 0.0f, 1.0f, 0.0f);

  // Setting color based on linear-interpolation colormap and adjusting alpha component...
  *color = (float4)(RMIN+(RMAX-RMIN)*p.z, 0.0f, BMIN+(BMAX-BMIN)*p.z, 1.0f);

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

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: LINK LENGTH ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      ll_1 = length(Ll_1);                                              // 1st link length.
  float4      ll_2 = length(Ll_2);                                              // 2nd link length.
  float4      ll_3 = length(Ll_3);                                              // 3rd link length.
  float4      ll_4 = length(Ll_4);                                              // 4th link length.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: LINK STRAIN ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      epsilon = fr + (float4)(1.0f, 1.0f, 1.0f, 1.0f);                  // Safety margin for division.
  float4      sl_1 = SAFEDIV(ll_1 - rl_1, ll_1, epsilon);                       // 1st link strain.
  float4      sl_2 = SAFEDIV(ll_2 - rl_2, ll_2, epsilon);                       // 2nd link strain.
  float4      sl_3 = SAFEDIV(ll_3 - rl_3, ll_3, epsilon);                       // 3rd link strain.
  float4      sl_4 = SAFEDIV(ll_4 - rl_4, ll_4, epsilon);                       // 4th link strain.

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

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////// SYNERGIC MOLECULE: GRAVITATIONAL FORCE ///////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Fg   = m*G;                                                       // Gravitational force applied to the particle.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: TOTAL FORCE ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      F    = fr*(Fe + Fv + Fg);                                         // Total force applied to the particle.

  return F;
}


__kernel void thekernel(__global float4*    position,
                        __global float4*    color,
                        __global float4*    position_int,
                        __global float4*    velocity,
                        __global float4*    velocity_int,
                        __global float4*    acceleration,
                        __global float4*    acceleration_int,
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

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// VERLET INTEGRATION ///////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  // linked particles displacements
  float4      Dl_1;
  float4      Dl_2;
  float4      Dl_3;
  float4      Dl_4;

  // Calculating acceleration at time t_n...
  compute_link_displacements(Pl_1, Pl_2, Pl_3, Pl_4, P, rl_1, rl_2, rl_3,
                                  rl_4, fr, &Dl_1, &Dl_2, &Dl_3, &Dl_4);

  float4 F = compute_particle_force(kl_1, kl_2, kl_3, kl_4, Dl_1, Dl_2, Dl_3, Dl_4,
                            c, V, m, G, fr);

  A = F/m;

  // Calculating and updating position of the center particle...
  P += V*DT + A*DT*DT/2.0f;

  // update positions in global memory
  position_int[gid] = P;
  velocity_int[gid] = V;
  acceleration_int[gid] = A;

}
