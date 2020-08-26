/// @file

__kernel void thekernel(__global float4*    position,                                               // Position [m].
                        __global float4*    color,                                                  // Depth color [#].
                        __global long*      stride                                                  // Stride [#].
                        )
{
        unsigned long gid = get_global_id(0);                                                       // Global index [#].
        float4 P = position[gid];                                                                   // Getting point coordinates [m]...
        float4 C = color[gid];                                                                      // Getting color coordinates [#]...
        long S1 = stride[gid];
        long S2 = stride[gid + 12];

        S1 = gid;
        S2 = gid + 12;

        P.x = S1/24.0f;
        C.x = S2/24.0f;

        printf("C = %f\n", C.x);

        position[gid] = P;                                                                          // Updating position [m]...
        color[gid] = C;                                                                             // Updating color...
        stride[gid] = S1;
        stride[gid + 12] = S2;
}
