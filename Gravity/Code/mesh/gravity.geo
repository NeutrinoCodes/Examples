//////////////////////////////////////////////////////////////////
//
//      D---------C
//      |         |
//      |         |
//      |         |
//      A---------B
//
//
//      y
//      |
//      |
//      o -----x
//     /
//    /
//   z
//
//////////////////////////////////////////////////////////////////

ds = 0.2;                                                       // Setting side discretization length...
x_min = -1.0;                                                   // Setting "x_min"...
x_max = +1.0;                                                   // Setting "x_max"...
y_min = -1.0;                                                   // Setting "y_min"...
y_max = +1.0;                                                   // Setting "y_max"...
z_min = -1.0;                                                   // Setting "z_min"...
z_max = +1.0;                                                   // Setting "z_max"...

Point(1) = {x_min, y_min, z_min, ds};                           // Setting point "A"...
Point(2) = {x_max, y_min, z_min, ds};                           // Setting point "B"...
Point(3) = {x_max, y_max, z_min, ds};                           // Setting point "C"...
Point(4) = {x_min, y_max, z_min, ds};                           // Setting point "D"...
Point(5) = {x_min, y_min, z_max, ds};                           // Setting point "E"...
Point(6) = {x_max, y_min, z_max, ds};                           // Setting point "F"...
Point(7) = {x_max, y_max, z_max, ds};                           // Setting point "G"...
Point(8) = {x_min, y_max, z_max, ds};                           // Setting point "H"...

Line(1) = {1, 2};                                               // Setting side "AB"...
Line(2) = {2, 3};                                               // Setting side "BC"...
Line(3) = {3, 4};                                               // Setting side "CD"...
Line(4) = {4, 1};                                               // Setting side "AD"...

Curve Loop(1) = {1, 2, 3, 4};                                   // Setting perimeter "ABCD"...

Plane Surface(1) = {1};                                         // Setting surface "ABCD"...

Transfinite Surface {1};                                        // Applying transfinite algorithm...
Recombine Surface {1};                                          // Recombining triangles into quadrangles...

out[] = Extrude {0.0 , 0.0, (z_max - z_min)}                    // Creating extrusion along z-axis...
{
  Surface{1};                                                   // Setting surface to be extruded...
  Layers{(z_max - z_min)/ds};
  Recombine;
};

Physical Volume(1) = out[1];                                    // Setting physical group...

Physical Curve(1) = {1, 2, 3, 4};                               // Setting group: perimeter "ABCD"...
Physical Curve(2) = {1};                                        // Setting group: side "AB"...
Physical Curve(3) = {4};                                        // Setting group: side "AD"...

Physical Point(1) = {1};
Physical Point(2) = {2};
Physical Point(3) = {3};
Physical Point(4) = {4};
Physical Point(5) = {5};
Physical Point(6) = {6};
Physical Point(7) = {7};
Physical Point(8) = {8};

Mesh 5;                                                         // Setting mesh type: quadrangles...

Mesh.SaveAll = 1;                                               // Saving all mesh nodes...