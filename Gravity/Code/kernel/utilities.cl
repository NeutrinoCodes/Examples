#ifndef utilities_cl
#define utilities_cl

#define ONE4 (float4)(1.0f, 1.0f, 1.0f, 1.0f)

float pippo(float4 A, float4 B, float4 C)
{
  float d;

  d = 1.0f;
  //d = (A.x*B.y - B.x*A.y)*C.z - (A.x*B.z - B.x*A-z)*C.y + (A.y*B.z - B.y*A.z)*C.x;

  return d;
}
/*
float curv2D(float4 A, float4 B, float4 C)
{
  float T;
  float c;

  A.w = 0.0f;
  B.w = 0.0f;
  C.w = 0.0f;

  T = 0.5f*sqrt(pown(det(A, B, ONE4), 2) + pown(B, C, ONE4) + pown(C, A, ONE4));
  c = 4.0f*T/(length(A - B)*length(B - C)*length(C - A));

  return c;
}

float curv3D(float4 P, float4 R, float4 U, float4 F, float4 L, float4 D, float4 B)
{
  float4 c;

  c = fabs(curv2D(U, P, D)*curv2D(R, P, L)*curv2D(F, P, B));

  return c;
}
*/
#endif
