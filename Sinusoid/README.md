# NEUTRINO EXAMPLES

_A fast and light library for GPU-based computation and interactive data visualization._

[www.neutrino.codes](http://www.neutrino.codes)

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2021

## Sinusoid example

This example is the "Hello world!" of Neutrino.

It shows the function `z = A*sin(k*x - omega*t) + A*cos(k*y - omega*t)` computed on a discrete
square array of points and animated in time.

The user can change the point of view of the simulation by acting on the mouse, or
trackpad. The same can be done by means of any GLFW compatible gamepad (e.g. PS4 Dual Shock gamepad).

The PS4 Dual Shock gamepad can be connected either via USB or bluetooth: in the latter case, the
"share" button and the "PS" button must be pressed for a while in order to start the pairing
procedure. On Windows, the [DS4Windows](https://ryochan7.github.io/ds4windows-site/) driver is necessary
in order to make the PS4 Dual Shock gamepad recognised by Windows.

Pressing "B" on the keyboard, the 3D graphics output will switch to a side-by-side 3D binocular projection.
Pressing "M" on the keyboard will restore the usual 3D monocular projection.
Pressing "E" on the keyboard will exit the application.

**For the compilation of this example please follow the generic instructions written in the
README.md file in the "Examples" root directory.**

**Once compiled, the executable can be found in the `Examples/build` directory.
The `build` directory is not repositored, it will be created locally along the build process.**

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2021
