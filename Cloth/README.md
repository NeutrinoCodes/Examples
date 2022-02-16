# NEUTRINO EXAMPLES

_A fast and light library for GPU-based computation and interactive data visualization._

[www.neutrino.codes](http://www.neutrino.codes)

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2021

[![Neutrino - Cloth](../Logos/Neutrino-Cloth.png)](https://www.youtube.com/watch?v=jYHdJxtJkGM)

## Cloth example

This example computes the real-time simulation of a square piece of cloth anchored by its four sides
in the "x-y" directions and hanging in a gravity field pointing downwards in the "z" direction.

The cloth has been discretized in a mesh of interconnected nodes having local mechanical properties
(e.g. elasticity and mass). At the beginning of the simulation the cloth is in a default unstressed
situation like somebody is sustaining it in all of its nodes against the gravity field. Immediately
after, the cloth is released in all nodes but the ones on the four anchored sides: the gravity
starts deforming it according the laws of physics and a rich dinamic structure of moving ripples can
be observed as the result of the propagation of numerous mechanical waves. Eventually, the cloth
reaches a steady condition when all oscillations have been damped by the internal friction.
The simulation uses the Verlet explicit time integration method.

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
