/// @file

__kernel void thekernel(__global float4*    color,                              // Color [#].
                        __global float4*    position,                           // Position [m].
                        __global int*       central,                            // Node.
                        __global int*       neighbour,                          // Neighbour.
                        __global int*       offset                              // Offset.
                        )
{
  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// INDICES ///////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  unsigned int i = get_global_id(0);                                            // Global index [#].
  unsigned int j = 0;                                                           // Neighbour stride index.
  unsigned int j_min = 0;                                                       // Neighbour stride minimun index.
  unsigned int j_max = offset[i];                                               // Neighbour stride maximum index.
  unsigned int k = 0;                                                           // Neighbour tuple index.
  unsigned int n = central[j_max - 1];                                          // Node index.

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// CELL VARIABLES //////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  float4        nearest           = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Neighbour node position.
  float4        link              = (float4)(0.0f, 0.0f, 0.0f, 1.0f);           // Neighbour link.
  float         L                 = 0.0f;                                       // Neighbour link length.
  float4        p                 = position[n];                                // Central node position (intermediate).

  // COMPUTING STRIDE MINIMUM INDEX:
  if (i == 0)
  {
    j_min = 0;                                                                  // Setting stride minimum (first stride)...
  }
  else
  {
    j_min = offset[i - 1];                                                      // Setting stride minimum (all others)...
  }

  // COMPUTING ELASTIC FORCE:
  for (j = j_min; j < j_max; j++)
  {
    k = neighbour[j];                                                           // Computing neighbour index...
    nearest = position[k];                                                      // Getting neighbour position...
    link = nearest - p;                                                         // Getting neighbour link vector...
    L = length(link);                                                           // Computing neighbour link length...
    color[j].xyz = colormap(50.0f*L);                                           // Setting color...
  }
}
