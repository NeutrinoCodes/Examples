# NEUTRINO EXAMPLES

_A fast and light library for GPU-based computation and interactive data visualization._

[www.neutrino.codes](http://www.neutrino.codes)

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2021

## Gravity example

This example computes the real-time simulation of a 3D continuum elastic body subjected to the presence
of an attractive central field. The body is discretized into particles, each of them having a mass and connected
to its first neighbours by springs. The color shows the local 3D gaussian curvature of body, as it changes in time
after the application of the central force field occurring at the beginning of the simulation.

The user can change the point of view of the simulation by acting on the mouse, or
trackpad. The same can be done by means of any GLFW compatible gamepad (e.g. PS4 Dual Shock gamepad).

The PS4 Dual Shock gamepad can be connected either via USB or bluetooth: in the latter case, the
"share" button and the "PS" button must be pressed for a while in order to start the pairing
procedure. On Windows, the [DS4Windows](https://ryochan7.github.io/ds4windows-site/) driver is necessary
in order to make the PS4 Dual Shock gamepad recognised by Windows.

**For the compilation of this example please follow the generic instructions written in the
README.md file in the "Examples" root directory.**

**Once compiled, the executable can be found in the `Examples/build` directory.
The `build` directory is not repositored, it will be created locally along the build process.**

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2021