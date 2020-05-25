# NEUTRINO EXAMPLES

_A fast and light library for GPU-based computation and interactive data visualization._

[www.neutrino.codes](http://www.neutrino.codes)

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2020

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
trackpad:
- grasping while keeping pressed the left button will orbit the view.
- grasping while keeping pressed the right button will pan the view.
- scrolling the mouse wheel (or using the trackpad scroll gesture the way it is configured in your
system) will zoom in/out the view.

The same can be done by means of any GLFW compatible gamepad (e.g. PS4 Dual Shock gamepad) in this
way:
- left analog joystick: orbit.
- right analog joystick: pan.
- L2 and R2 buttons (triggers): zoom in/out.

The PS4 Dual Shock gamepad can be connected either via USB or bluetooth: in the latter case, the
"share" button and the "PS" button must be pressed for a while in order to start the pairing
procedure.

The initial point of view has been set by putting the observer above the cloth ("x-y" plane aligned
with the computer screen, "x" axis pointing up, "y" axis pointing right, "z" axis pointing inside
the screen).

The simulation can be terminated by pressing "ESC" on the keyboard or by pressing the "CROSS" button
on the gamepad.

Pressing "3" on the keyboard, the 3D graphics output will switch to a side-by-side 3D stereoscopic projection.
Pressing "2" on the keyboard will restore the usual 3D monoscopic projection.

**For the compilation of this example please follow the generic instructions written in the
README.md file in the "Examples" root directory.**

**Once compiled, the executable can be found in the `Examples/build` directory.
The `build` directory is not repositored, it will be created locally along the build process.**

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2020
