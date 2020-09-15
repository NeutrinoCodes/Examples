/// @file

#version 460 core

in  vec4 out_color;                                                             // Voxel color.
out vec4 fragment_color;                                                        // Fragment color.

void main(void)
{
  fragment_color = out_color;                                                   // Setting fragment color...
}
