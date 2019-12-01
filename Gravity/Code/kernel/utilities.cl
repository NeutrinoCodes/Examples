#ifndef utilities_cl
#define utilities_cl

#define SAFEDIV(X, Y, EPSILON)    (X)/(Y + EPSILON)
#define RMIN                      0.4f                                          // Offset red channel for colormap
#define RMAX                      0.5f                                          // Maximum red channel for colormap
#define BMIN                      0.0f                                          // Offset blue channel for colormap
#define BMAX                      1.0f                                          // Maximum blue channel for colormap
#define SCALE                     1.5f                                          // Scale factor for plot

void link_displacements (
        float4 position_R,                                                      // Right neighbour position [m].
        float4 position_U,                                                      // Up neighbour position [m].
        float4 position_F,                                                      // Front neighbour position [m].
        float4 position_L,                                                      // Left neighbour position [m].
        float4 position_D,                                                      // Down neighbour position [m].
        float4 position_B,                                                      // Back neighbour position [m].
        float4 P,                                                               // Position [m].
        float4 resting_R,                                                       // Right neighbour resting position [m].
        float4 resting_U,                                                       // Up neighbour resting position [m].
        float4 resting_F,                                                       // Front neighbour resting position [m].
        float4 resting_L,                                                       // Left neighbour resting position [m].
        float4 resting_D,                                                       // Down neighbour resting position [m].
        float4 resting_B,                                                       // Back neighbour resting position [m].
        float4 fr,                                                              // Freedom flag [#].
        float4* displacement_R,                                                 // Right neighbour displacement [m].
        float4* displacement_U,                                                 // Up neighbour displacement [m].
        float4* displacement_F,                                                 // Front neighbour displacement [m].
        float4* displacement_L,                                                 // Left neighbour displacement [m].
        float4* displacement_D,                                                 // Down neighbour displacement [m].
        float4* displacement_B                                                  // Back neighbour displacement [m].
        )
{
        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////// SYNERGIC MOLECULE: LINKED NODE VECTOR ///////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 link_R = position_R - P;                                         // Right neighbour link vector.
        float4 link_U = position_U - P;                                         // Up neighbour link vector.
        float4 link_F = position_F - P;                                         // Front neighbour link vector.
        float4 link_L = position_L - P;                                         // Left neighbour link vector.
        float4 link_D = position_D - P;                                         // Down neighbour link vector.
        float4 link_B = position_B - P;                                         // Back neighbour link vector.

        ////////////////////////////////////////////////////////////////////////////////
        ///////////////////////// SYNERGIC MOLECULE: LINK LENGTH ///////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 length_R = length(link_R);                                       // Right neighbour link length.
        float4 length_U = length(link_U);                                       // Up neighbour link length.
        float4 length_F = length(link_F);                                       // Front neighbour link length.
        float4 length_L = length(link_L);                                       // Left neighbour link length.
        float4 length_D = length(link_D);                                       // Down neighbour link length.
        float4 length_B = length(link_B);                                       // Back neighbour link length.

        ////////////////////////////////////////////////////////////////////////////////
        ///////////////////////// SYNERGIC MOLECULE: LINK STRAIN ///////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 epsilon = (float4)(1.0f, 1.0f, 1.0f, 1.0f) - fr;                 // Safety margin for division.
        float4 strain_R = length_R - resting_R;                                 // Right neighbour link strain.
        float4 strain_U = length_U - resting_U;                                 // Up neighbour link strain.
        float4 strain_F = length_F - resting_F;                                 // Front neighbour link strain.
        float4 strain_L = length_L - resting_L;                                 // Left neighbour link strain.
        float4 strain_D = length_D - resting_D;                                 // Down neighbour link strain.
        float4 strain_B = length_B - resting_B;                                 // Back neighbour link strain.

        ////////////////////////////////////////////////////////////////////////////////
        //////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT ///////////////
        ////////////////////////////////////////////////////////////////////////////////
        *displacement_R = strain_R*SAFEDIV(link_R, length_R, epsilon);          // Right neighbour link displacement.
        *displacement_U = strain_U*SAFEDIV(link_U, length_U, epsilon);          // Up neighbour link displacement.
        *displacement_F = strain_F*SAFEDIV(link_F, length_F, epsilon);          // Front neighbour link displacement.
        *displacement_L = strain_L*SAFEDIV(link_L, length_L, epsilon);          // Left neighbour link displacement.
        *displacement_D = strain_D*SAFEDIV(link_D, length_D, epsilon);          // Down neighbour link displacement.
        *displacement_B = strain_B*SAFEDIV(link_B, length_B, epsilon);          // Back neighbour link displacement.
}

float4 node_force (
        float4 stiffness_R,                                                     // Right neighbour stiffness.
        float4 stiffness_U,                                                     // Up neighbour stiffness.
        float4 stiffness_F,                                                     // Front neighbour stiffness.
        float4 stiffness_L,                                                     // Left neighbour stiffness.
        float4 stiffness_D,                                                     // Down neighbour stiffness.
        float4 stiffness_B,                                                     // Back neighbour stiffness.
        float4 displacement_R,                                                  // Right neighbour displacement [m].
        float4 displacement_U,                                                  // Up neighbour displacement [m].
        float4 displacement_F,                                                  // Front neighbour displacement [m].
        float4 displacement_L,                                                  // Left neighbour displacement [m].
        float4 displacement_D,                                                  // Down neighbour displacement [m].
        float4 displacement_B,                                                  // Back neighbour displacement [m].
        float4 C,                                                               // Friction coefficient.
        float4 V,                                                               // Velocity [m/s].
        float4 m,                                                               // Mass [kg].
        float4 g,                                                               // Gravity [m/s^2].
        float4 fr                                                               // Freedom flag [#].
        )
{
        ////////////////////////////////////////////////////////////////////////////////
        //////////////////////// SYNERGIC MOLECULE: ELASTIC FORCE //////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        // Elastic force applied to the particle:
        float4 Fe   = (
                stiffness_R*displacement_R +
                stiffness_U*displacement_U +
                stiffness_F*displacement_F +
                stiffness_L*displacement_L +
                stiffness_D*displacement_D +
                stiffness_B*displacement_B
                );

        ////////////////////////////////////////////////////////////////////////////////
        //////////////////////// SYNERGIC MOLECULE: VISCOUS FORCE //////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 Fv   = -C*V;                                                     // Viscous force applied to the particle.

        ////////////////////////////////////////////////////////////////////////////////
        ///////////////////// SYNERGIC MOLECULE: GRAVITATIONAL FORCE ///////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 Fg   = m*g;                                                      // Gravitational force applied to the particle.

        ////////////////////////////////////////////////////////////////////////////////
        ///////////////////////// SYNERGIC MOLECULE: TOTAL FORCE ///////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 F    = fr*(Fe + Fv + Fg);                                        // Total force applied to the particle.

        return F;
}

void fix_projective_space (
        float4* vector
        )
{
        *vector *= (float4)(1.0f, 1.0f, 1.0f, 0.0f);                            // Nullifying 4th projective component...

        *vector += (float4)(0.0f, 0.0f, 0.0f, 1.0f);                            // Setting 4th projective component to "1.0f"...
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
