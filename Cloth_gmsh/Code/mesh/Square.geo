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


ds = 0.05;                                                      // Setting side partitioning length...

Point(1) = {0.0, 0.0, 0.0, ds};                                 // Setting point "A"...
Point(2) = {1.0, 0.0, 0.0, ds};                                 // Setting point "B"...
Point(3) = {1.0, 1.0, 0.0, ds};                                 // Setting point "C"...
Point(4) = {0.0, 1.0, 0.0, ds};                                 // Setting point "D"...

Line(1) = {1, 2};                                               // Setting side "AB"...
Line(2) = {2, 3};                                               // Setting side "BC"...
Line(3) = {3, 4};                                               // Setting side "CD"...
Line(4) = {4, 1};                                               // Setting side "AD"...

Curve Loop(1) = {1, 2, 3, 4};                                   // Setting perimeter "ABCD"...

Plane Surface(1) = {1};                                         // Setting surface "ABCD"...

Physical Curve(1) = {1, 2, 3, 4};                               // Setting group: perimeter "ABCD"...
Physical Curve(2) = {1};                                        // Setting group: side "AB"...
Physical Curve(3) = {4};                                        // Setting group: side "AD"...

Mesh 2;                                                         // Setting mesh type: triangles...
Mesh.SaveAll = 1;                                               // Saving all mesh nodes...