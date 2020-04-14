#ifndef utilities_cl
#define utilities_cl

float sum_float(float a, float b, float epsilon, float* c, float* error)
{

}

float gravity(float r, float R0)
{
        return clamp(r, 0, R0) + pown(step(R0, r)*r, -2);
}

float strain(float Pa, float Pb, float R0, float Rmax)
{
        if (length(Pb - Pa) == 0)
        {
                Fe = (float4)(0.0, 0.0, 0.0, 1.0);
        }
        else
        {

        }
        return (clamp(L, R0, Rmax) - clamp(R, R0, Rmax))/clamp(L, R0, Rmax);
}

void fix_projective_space (float4* vector)
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
