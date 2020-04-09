#ifndef utilities_cl
#define utilities_cl

#define SAFEDIV(X, Y, EPSILON)    (X)/(Y + EPSILON)

void links(

        )
{

}

void displacements (
        float4 P,                                                                               // Position [m].
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

        //////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////// SYNERGIC MOLECULE: LINK STRAIN ////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 epsilon = (float4)(1.0f, 1.0f, 1.0f, 1.0f) - fr;                                     // Safety margin for division.

        float strain_R = SAFEDIV(length_R - resting_R, length_R, epsilon);                          // Right neighbour link strain.
        float strain_U = SAFEDIV(length_U - resting_U, length_U, epsilon);                          // Up neighbour link strain.
        float strain_F = SAFEDIV(length_F - resting_F, length_F, epsilon);                          // Front neighbour link strain.
        float strain_L = SAFEDIV(length_L - resting_L, length_L, epsilon);                          // Left neighbour link strain.
        float strain_D = SAFEDIV(length_D - resting_D, length_D, epsilon);                          // Down neighbour link strain.
        float strain_B = SAFEDIV(length_B - resting_B, length_B, epsilon);                          // Back neighbour link strain.

        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////// SYNERGIC MOLECULE: LINKED PARTICLE DISPLACEMENT /////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        *displacement_R = strain_R*link_R;                                                          // Right neighbour link displacement.
        *displacement_U = strain_U*link_U;                                                          // Up neighbour link displacement.
        *displacement_F = strain_U*link_F;                                                          // Front neighbour link displacement.
        *displacement_L = strain_U*link_L;                                                          // Left neighbour link displacement.
        *displacement_D = strain_U*link_D;                                                          // Down neighbour link displacement.
        *displacement_B = strain_U*link_B;                                                          // Back neighbour link displacement.
}

void dispatches(
        float4 V,                                                                                   // Position [m].
        float4 velocity_R,                                                                          // Right neighbour velocity [m].
        float4 velocity_U,                                                                          // Up neighbour velocity [m].
        float4 velocity_F,                                                                          // Front neighbour velocity [m].
        float4 velocity_L,                                                                          // Left neighbour velocity [m].
        float4 velocity_D,                                                                          // Down neighbour velocity [m].
        float4 velocity_B,                                                                          // Back neighbour velocity [m].
        float4* dispatch_R,                                                                         // Right neighbour dispatch [m/s].
        float4* dispatch_U,                                                                         // Up neighbour dispatch [m/s].
        float4* dispatch_F,                                                                         // Front neighbour dispatch [m/s].
        float4* dispatch_L,                                                                         // Left neighbour dispatch [m/s].
        float4* displatch_D,                                                                        // Down neighbour dispatch [m/s].
        float4* displatch_B                                                                         // Back neighbour dispatch [m/s].
        )
{
        *dispatch_R = velocity_R - V;                                                               // Right neighbour dispatch [m/s].
        *dispatch_U = velocity_U - V;                                                               // Up neighbour dispatch [m/s].
        *dispatch_F = velocity_F - V;                                                               // Front neighbour dispatch [m/s].
        *dispatch_L = velocity_L - V;                                                               // Left neighbour dispatch [m/s].
        *dispatch_D = velocity_D - V;                                                               // Down neighbour dispatch [m/s].
        *dispatch_B = velocity_B - V;                                                               // Back neighbour dispatch [m/s].
}

float4 node_force (
        stiffness_R,                                                                                // Right neighbour stiffness.
        stiffness_U,                                                                                // Up neighbour stiffness.
        stiffness_F,                                                                                // Front neighbour stiffness.
        stiffness_L,                                                                                // Left neighbour stiffness.
        stiffness_D,                                                                                // Down neighbour stiffness.
        stiffness_B,                                                                                // Back neighbour stiffness.
        friction_R,                                                                                 // Right neighbour friction.
        friction_U,                                                                                 // Up neighbour friction.
        friction_F,                                                                                 // Front neighbour friction.
        friction_L,                                                                                 // Left neighbour friction.
        friction_D,                                                                                 // Down neighbour friction.
        friction_B,                                                                                 // Back neighbour friction.
        displacement_R,                                                                             // Right neighbour displacement [m].
        displacement_U,                                                                             // Up neighbour displacement [m].
        displacement_F,                                                                             // Front neighbour displacement [m].
        displacement_L,                                                                             // Left neighbour displacement [m].
        displacement_D,                                                                             // Down neighbour displacement [m].
        displacement_B,                                                                             // Back neighbour displacement [m].
        dispatch_R,                                                                                 // Right neighbour velocity [m].
        dispatch_U,                                                                                 // Up neighbour velocity [m].
        dispatch_F,                                                                                 // Front neighbour velocity [m].
        dispatch_L,                                                                                 // Left neighbour velocity [m].
        dispatch_D,                                                                                 // Down neighbour velocity [m].
        dispatch_B,                                                                                 // Back neighbour velocity [m].
        P,                                                                                          // Position [m].
        V,                                                                                          // Velocity [m/s].
        m,                                                                                          // Mass [kg].
        fr                                                                                          // Freedom flag [#].
        )
{
        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: ELASTIC FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        float4 Fe   = (
                stiffness_R*displacement_R +
                stiffness_U*displacement_U +
                stiffness_F*displacement_F +
                stiffness_L*displacement_L +
                stiffness_D*displacement_D +
                stiffness_B*displacement_B
                );

        //////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////// SYNERGIC MOLECULE: VISCOUS FORCE ///////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // Elastic force applied to the particle:
        float4 Fv   = -(
                friction_R*(velocity_R - V)+
                friction_U*(velocity_U - V)+
                friction_F*(velocity_F - V)+
                friction_L*(velocity_L - V)+
                friction_D*(velocity_D - V)+
                friction_B*(velocity_B - V)
                );



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
