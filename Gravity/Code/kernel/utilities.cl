#ifndef utilities_cl
#define utilities_cl

#define SAFEDIV(X, Y, EPSILON)    (X)/(Y + EPSILON)

void link_displacements (
        float4 P,                                                                                   // Position [m].
        float4 position_R,                                                                          // Right neighbour position [m].
        float4 position_U,                                                                          // Up neighbour position [m].
        float4 position_F,                                                                          // Front neighbour position [m].
        float4 position_L,                                                                          // Left neighbour position [m].
        float4 position_D,                                                                          // Down neighbour position [m].
        float4 position_B,                                                                          // Back neighbour position [m].
        float4 resting,                                                                             // Right neighbour resting position [m].
        float4* displacement_R,                                                                     // Right neighbour displacement [m].
        float4* displacement_U,                                                                     // Up neighbour displacement [m].
        float4* displacement_F,                                                                     // Front neighbour displacement [m].
        float4* displacement_L,                                                                     // Left neighbour displacement [m].
        float4* displacement_D,                                                                     // Down neighbour displacement [m].
        float4* displacement_B                                                                      // Back neighbour displacement [m].
        )
{
        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// SYNERGIC MOLECULE: LINKED NODE VECTOR //////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 link_R = position_R - P;                                                             // Right neighbour link vector.
        float4 link_U = position_U - P;                                                             // Up neighbour link vector.
        float4 link_F = position_F - P;                                                             // Front neighbour link vector.
        float4 link_L = position_L - P;                                                             // Left neighbour link vector.
        float4 link_D = position_D - P;                                                             // Down neighbour link vector.
        float4 link_B = position_B - P;                                                             // Back neighbour link vector.

        //////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////// SYNERGIC MOLECULE: LINK LENGTH ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float length_R = length(link_R);                                                            // Right neighbour link length.
        float length_U = length(link_U);                                                            // Up neighbour link length.
        float length_F = length(link_F);                                                            // Front neighbour link length.
        float length_L = length(link_L);                                                            // Left neighbour link length.
        float length_D = length(link_D);                                                            // Down neighbour link length.
        float length_B = length(link_B);                                                            // Back neighbour link length.

        ////////////////////////////////////////////////////////////////////////////////
        ///////////////////////// SYNERGIC MOLECULE: LINK STRAIN ///////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        float4 epsilon = (float4)(1.0f, 1.0f, 1.0f, 1.0f) - fr;                 // Safety margin for division.
        float strain_R = SAFEDIV(length_R - resting_R, length_R, epsilon);     // Right neighbour link strain.


        ////////////////////////////////////////////////////////////////////////////////
        //////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT ///////////////
        ////////////////////////////////////////////////////////////////////////////////
        *displacement_R = link_R*strain_R;                                      // Right neighbour link displacement.

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
        float4 link_R = position_R - P;                                         // Right neighbour link vector.
        float4 link_U = position_U - P;                                         // Up neighbour link vector.
        float4 link_F = position_F - P;                                         // Front neighbour link vector.
        float4 link_L = position_L - P;                                         // Left neighbour link vector.
        float4 link_D = position_D - P;                                         // Down neighbour link vector.
        float4 link_B = position_B - P;                                         // Back neighbour link vector.

        float length_R = length(link_R);                                       // Right neighbour link length.
        float length_U = length(link_U);                                       // Up neighbour link length.
        float length_F = length(link_F);                                       // Front neighbour link length.
        float length_L = length(link_L);                                       // Left neighbour link length.
        float length_D = length(link_D);                                       // Down neighbour link length.
        float length_B = length(link_B);                                       // Back neighbour link length.

        float epsilon = 1.0f - fr.x;                 // Safety margin for division.

        float Fg_R = link_R*SAFEDIV(1.0f, length_R*length_R*length_R, epsilon);
        float Fg_U = link_U*SAFEDIV(1.0f, length_U*length_U*length_U, epsilon);
        float Fg_F = link_F*SAFEDIV(1.0f, length_F*length_F*length_F, epsilon);
        float Fg_L = link_L*SAFEDIV(1.0f, length_L*length_L*length_L, epsilon);
        float Fg_D = link_D*SAFEDIV(1.0f, length_D*length_D*length_D, epsilon);
        float Fg_B = link_B*SAFEDIV(1.0f, length_B*length_B*length_B, epsilon);

        float4 Fg   = Fg_R + Fg_U + Fg_F + Fg_L + Fg_D + Fg_B;                  // Gravitational force applied to the particle.

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
void assign_color(float4* color, float4* gravity)
{
        //*color = (float4)(100.0f*length(*gravity), 1.0f, 1.0f, 1.0f);
}

#endif
