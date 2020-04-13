#ifndef utilities_cl
#define utilities_cl

float sum_float(float a, float b, float epsilon, float* c, float* error)
{

}

float gravity(float r, float R0)
{
        return clamp(r, 0, R0) + pown(step(R0, r)*r, -2);
}

float strain(float L, float R, float R0, float Rmax)
{
        float La = length(Pa);
        float Lb = length(Pb);
        if ((La < epsilon) && (Lb < epsilon))
        {
                Pa *= 1000.0;
                Pb *= 1000.0;
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
