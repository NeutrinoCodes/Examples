dx = 0.05;

Point(1) = {0.0, 0.0, 0.0, dx};
Point(2) = {1.0, 0.0, 0.0, dx};
Point(3) = {1.0, 1.0, 0.0, dx};
Point(4) = {0.0, 1.0, 0.0, dx};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Curve Loop(1) = {1, 2, 3, 4};

Plane Surface(1) = {1};

Physical Curve(1) = {1, 2, 3, 4};

Mesh 2;

Mesh.SaveAll = 1;