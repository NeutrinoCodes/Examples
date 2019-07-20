#ifndef utilities_cl
#define utilities_cl

#include "client_datatypes.cl"

#define SAFEDIV(X, Y, EPSILON)    (X)/(Y + EPSILON)
#define RMIN                      0.4f                                          // Offset red channel for colormap
#define RMAX                      0.5f                                          // Maximum red channel for colormap
#define BMIN                      0.0f                                          // Offset blue channel for colormap
#define BMAX                      1.0f                                          // Maximum blue channel for colormap
#define SCALE                     1.5f                                          // Scale factor for plot

void link_displacements (
                          float4 P_R,                                           // Right neighbour position [m].
                          float4 P_U,                                           // Up neighbour position [m].
                          float4 P_L,                                           // Left neighbour position [m].
                          float4 P_D,                                           // Down neighbour position [m].
                          float4 P,                                             // Position [m].
                          float4 resting_R,                                     // Right neighbour resting position [m].
                          float4 resting_U,                                     // Up neighbour resting position [m].
                          float4 resting_L,                                     // Left neighbour resting position [m].
                          float4 resting_D,                                     // Down neighbour resting position [m].
                          float4 fr,                                            // Freedom flag [#].
                          float4* D_R,                                          // Right neighbour displacement [m].
                          float4* D_U,                                          // Up neighbour displacement [m].
                          float4* D_L,                                          // Left neighbour displacement [m].
                          float4* D_D                                           // Down neighbour displacement [m].
                        )
{
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////// SYNERGIC MOLECULE: LINKED NODE VECTOR ///////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      L_R = P_R - P;                                                    // Right neighbour link vector.
  float4      L_U = P_U - P;                                                    // Up neighbour link vector.
  float4      L_L = P_L - P;                                                    // Left neighbour link vector.
  float4      L_D = P_D - P;                                                    // Down neighbour link vector.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: LINK LENGTH ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      l_R = length(L_R);                                                // Right neighbour link length.
  float4      l_U = length(L_U);                                                // Up neighbour link length.
  float4      l_L = length(L_L);                                                // Left neighbour link length.
  float4      l_D = length(L_D);                                                // Down neighbour link length.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: LINK STRAIN ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      epsilon = fr - (float4)(1.0f, 1.0f, 1.0f, 1.0f);                  // Safety margin for division.
  float4      strain_R = l_R - resting_R;                                       // Right neighbour link strain.
  float4      strain_U = l_U - resting_U;                                       // Up neighbour link strain.
  float4      strain_L = l_L - resting_L;                                       // Left neighbour link strain.
  float4      strain_D = l_D - resting_D;                                       // Down neighbour link strain.

  ////////////////////////////////////////////////////////////////////////////////
  //////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT ///////////////
  ////////////////////////////////////////////////////////////////////////////////
  *D_R = strain_R*SAFEDIV(L_R, l_R, epsilon);                                   // Right neighbour link displacement.
  *D_U = strain_U*SAFEDIV(L_U, l_U, epsilon);                                   // Up neighbour link displacement.
  *D_L = strain_L*SAFEDIV(L_L, l_L, epsilon);                                   // Left neighbour link displacement.
  *D_D = strain_D*SAFEDIV(L_D, l_D, epsilon);                                   // Down neighbour link displacement.
}

float4 node_force (
                    float4  k_R,                                                // Right neighbour stiffness.
                    float4  k_U,                                                // Right neighbour stiffness.
                    float4  k_L,                                                // Right neighbour stiffness.
                    float4  k_D,                                                // Right neighbour stiffness.
                    float4  D_R,                                                // Right neighbour displacement [m].
                    float4  D_U,                                                // Up neighbour displacement [m].
                    float4  D_L,                                                // Left neighbour displacement [m].
                    float4  D_D,                                                // Down neighbour displacement [m].
                    float4  C,                                                  // Friction coefficient.
                    float4  V,                                                  // Velocity [m/s].
                    float4  m,                                                  // Mass [kg].
                    float4  g,                                                  // Gravity [m/s^2].
                    float4  fr                                                  // Freedom flag [#].
                  )
{
  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// SYNERGIC MOLECULE: ELASTIC FORCE //////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Fe   = (k_R*D_R + k_U*D_U + k_L*D_L + k_D*D_D);           // Elastic force applied to the particle.

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// SYNERGIC MOLECULE: VISCOUS FORCE //////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Fv   = -C*V;                                                      // Viscous force applied to the particle.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////// SYNERGIC MOLECULE: GRAVITATIONAL FORCE ///////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      Fg   = m*g;                                                       // Gravitational force applied to the particle.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// SYNERGIC MOLECULE: TOTAL FORCE ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4      F    = fr*(Fe + Fv + Fg);                                         // Total force applied to the particle.

  return F;
}

void fix_projective_space (
                            float4* vector
                          )
{
  *vector *= (float4)(1.0f, 1.0f, 1.0f, 0.0f);                                  // Nullifying 4th projective component...

  *vector += (float4)(0.0f, 0.0f, 0.0f, 1.0f);                                  // Setting 4th projective component to "1.0f"...
}

// Assign color based on a custom colormap.
void assign_color(float4* color, float4* position)
{
  // Taking the component-wise absolute value of the position vector...
  float4 p = fabs(*position)*SCALE;

  // Extracting the z-component of the displacement...
  p *= (float4)(0.0f, 0.0f, 1.0f, 0.0f);

  // Setting color based on linear-interpolation colormap and adjusting alpha component...
  *color = (float4)(RMIN+(RMAX-RMIN)*p.z, 0.0f, BMIN+(BMAX-BMIN)*p.z, 1.0f);
}

#endif
