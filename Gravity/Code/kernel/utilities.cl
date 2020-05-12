#ifndef utilities_cl
#define utilities_cl

#define ONE4 (float4)(1.0f, 1.0f, 1.0f, 1.0f)

float det(float4 row_1, float4 row_2, float4 row_3)
{
  float d;

  d = (row_1.x*row_2.y - row_1.y*row_2.x)*row_3.z -
      (row_1.x*row_3.y - row_1.y*row_3.x)*row_2.z +
      (row_2.x*row_3.y - row_2.y*row_3.x)*row_1.z;

  return d;
}

float curv2D(float4 A, float4 B, float4 C)
{
  float T;
  float c;
  float4 X;
  float4 Y;
  float4 Z;

  A.w = 0.0f;
  B.w = 0.0f;
  C.w = 0.0f;

  X.x = A.x;
  X.y = B.x;
  X.z = C.x;
  X.w = 0.0f;

  Y.x = A.y;
  Y.y = B.y;
  Y.z = C.y;
  Y.w = 0.0f;

  Z.x = A.z;
  Z.y = B.z;
  Z.z = C.z;
  Z.w = 0.0f;

  T = 0.5f*sqrt(pown(det(X, Y, ONE4), 2) + pown(det(Y, Z, ONE4), 2) + pown(det(Z, X, ONE4), 2));
  c = 4.0f*T/(length(A - B)*length(B - C)*length(C - A));

  return c;
}

float curv3D(float4 P, float4 R, float4 U, float4 F, float4 L, float4 D, float4 B)
{
  float c;

  c = fabs(curv2D(U, P, D)*curv2D(R, P, L)*curv2D(F, P, B));

  return c;
}

#endif
