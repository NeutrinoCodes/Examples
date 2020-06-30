/// @file

#ifndef utilities_cl
#define utilities_cl

#define ONE4 (float4)(1.0f, 1.0f, 1.0f, 1.0f)                                                       // Vector of 4 ones.

// Determinant of 3x3 matrix.
float det(float4 row_1, float4 row_2, float4 row_3)
{
  float d;                                                                                          // Determinant.

  d = (row_1.x*row_2.y - row_1.y*row_2.x)*row_3.z -
      (row_1.x*row_3.y - row_1.y*row_3.x)*row_2.z +
      (row_2.x*row_3.y - row_2.y*row_3.x)*row_1.z;

  return d;
}

// 2D Gaussian discrete curvature (Menger).
float curv2D(float4 A, float4 B, float4 C)
{
  float T;                                                                                          // Area of triangle ABC [m^2].
  float c;                                                                                          // Curvature [1/m].
  float4 X;                                                                                         // x-coordinates of all triangle sides [m].
  float4 Y;                                                                                         // y-coordinates of all triangle sides [m].
  float4 Z;                                                                                         // z-coordinates of all triangle sides [m].

  A.w = 0.0f;                                                                                       // Resetting w-coordinate...
  B.w = 0.0f;                                                                                       // Resetting w-coordinate...
  C.w = 0.0f;                                                                                       // Resetting w-coordinate...

  X.x = A.x;                                                                                        // Setting x-coordinate [m]...
  X.y = B.x;                                                                                        // Setting x-coordinate [m]...
  X.z = C.x;                                                                                        // Setting x-coordinate [m]...
  X.w = 0.0f;                                                                                       // Setting x-coordinate [m]...

  Y.x = A.y;                                                                                        // Setting y-coordinate [m]...
  Y.y = B.y;                                                                                        // Setting y-coordinate [m]...
  Y.z = C.y;                                                                                        // Setting y-coordinate [m]...
  Y.w = 0.0f;                                                                                       // Setting y-coordinate [m]...

  Z.x = A.z;                                                                                        // Setting z-coordinate [m]...
  Z.y = B.z;                                                                                        // Setting z-coordinate [m]...
  Z.z = C.z;                                                                                        // Setting z-coordinate [m]...
  Z.w = 0.0f;                                                                                       // Setting z-coordinate [m]...

  T = 0.5f*sqrt(pown(det(X, Y, ONE4), 2) + pown(det(Y, Z, ONE4), 2) + pown(det(Z, X, ONE4), 2));    // Computing triangle area [m^2]...
  c = 4.0f*T/(length(A - B)*length(B - C)*length(C - A));                                           // Computing curvature [1/m]...

  return c;
}

// 3D Gaussian discrete curvature (Menger).
float curv3D(float4 P, float4 R, float4 U, float4 F, float4 L, float4 D, float4 B)
{
  float c;                                                                                          // Curvature [1/m].

  c = fabs(curv2D(U, P, D)*curv2D(R, P, L)*curv2D(F, P, B));                                        // Computing curvature [1/m]...

  return c;
}

#endif
