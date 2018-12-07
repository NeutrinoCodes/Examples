/// @file

#define SIZE_WINDOW_X  800                                                      // Window x-size [px].
#define SIZE_WINDOW_Y  600                                                      // Window y-size [px].
#define WINDOW_NAME    "cloth 2.0"                                           // Window name.

#define KDIM           1

#define XMIN          -1.0
#define XMAX           1.0
#define YMIN          -1.0
#define YMAX           1.0
#define NODES_X        100
#define NODES_Y        100
#define NODES          NODES_X*NODES_Y                                          // Number of nodes.
#define DX             (XMAX - XMIN)/(float)(NODES_X - 1)
#define DY             (YMAX - YMIN)/(float)(NODES_Y - 1)

#include "neutrino.hpp"
#include "window.hpp"
#include "opencl.hpp"
#include "queue.hpp"
#include "kernel.hpp"
#include "int1.hpp"
#include "int4.hpp"
#include "float1.hpp"
#include "float4.hpp"

int main()
{
  neutrino* baseline        = new neutrino();                                   // The Neutrino object.
  window*   gui             = new window();                                     // The gui window object.
  opencl*   cl              = new opencl();                                     // The OpenCL context object.

  queue*    q1              = new queue();                                      // OpenCL queue.

  size_t*   k1_size         = new size_t[KDIM];
  kernel*   k1              = new kernel();                                     // OpenCL kernel.
  size_t*   k2_size         = new size_t[KDIM];
  kernel*   k2              = new kernel();                                     // OpenCL kernel.

  point4* position          = new point4();                             // Position.
  color4* color             = new color4();                             // Particle color.
  float4* velocity          = new float4();                             // Velocity.
  float4* acceleration      = new float4();                             // Acceleration.

  float4* position_int      = new float4();                             // Position (intermediate).
  float4* velocity_int      = new float4();                             // Velocity (intermediate).
  float4* acceleration_int  = new float4();                             // Acceleration (intermediate).

  float4* gravity           = new float4();                             // Gravity.
  float4* stiffness         = new float4();                             // Stiffness.
  float4* resting           = new float4();                             // Resting.
  float4* friction          = new float4();                             // Friction.
  float4* mass              = new float4();                             // Mass.

  int1* index_PR            = new int1();                               // Right particle.
  int1* index_PU            = new int1();                               // Up particle.
  int1* index_PL            = new int1();                               // Left particle.
  int1* index_PD            = new int1();                               // Down particle.

  float4* freedom           = new float4();                             // Freedom/constrain flag.

  float1* dt                = new float1();                                      // Time step.
  float   simulation_time;                                                        // Simulation time.
  int     time_step_number;                                                       // Time step index.

  size_t    i;
  size_t    j;
  float x;
  float y;

  k1_size[0] = NODES;

  baseline  ->init();                                                           // Initializing neutrino...
  gui       ->init(baseline, SIZE_WINDOW_X, SIZE_WINDOW_Y, WINDOW_NAME);        // Initializing window...
  cl        ->init(baseline, gui->glfw_window, GPU);                            // Initializing OpenCL context...

  k1        ->init(
                    baseline,
                    "../../kernel/thekernel1.cl",
                    k1_size,
                    KDIM
                  );

  k1        ->init(
                    baseline,
                    "../../kernel/thekernel2.cl",
                    k2_size,
                    KDIM
                  );

  q1        ->init(baseline);


  position->init(baseline, NODES);                                                             // Initializing kernel variable...
  position_int->init(baseline, NODES);
  color->init(baseline, NODES);                                                                // Initializing kernel variable...
  velocity->init(baseline, NODES);                                                             // Initializing kernel variable...
  velocity_int->init(baseline, NODES);
  acceleration->init(baseline, NODES);                                                         // Initializing kernel variable...
  acceleration_int->init(baseline, NODES);
  gravity->init(baseline, NODES);                                                              // Initializing kernel variable...
  stiffness->init(baseline, NODES);                                                            // Initializing kernel variable...
  resting->init(baseline, NODES);                                                              // Initializing kernel variable...
  friction->init(baseline, NODES);                                                             // Initializing kernel variable...
  mass->init(baseline, NODES);                                                                 // Initializing kernel variable...
  index_PR->init(baseline, NODES);                                                             // Initializing kernel variable...
  index_PU->init(baseline, NODES);                                                             // Initializing kernel variable...
  index_PL->init(baseline, NODES);                                                             // Initializing kernel variable...
  index_PD->init(baseline, NODES);                                                             // Initializing kernel variable...
  freedom->init(baseline, NODES);                                                              // Initializing kernel variable...
  dt->init(baseline, 1);

  position->set(baseline, k1, 0);                                                         // Setting kernel argument #0...
  color->set(baseline, k1, 1);                                                           // Setting kernel argument #1...
  position_int->set(baseline, k1, 2);                                                         // Setting kernel argument #0...
  velocity->set(baseline, k1, 3);                                                         // Setting kernel argument #3...
  velocity_int->set(baseline, k1, 4);                                                          // Setting kernel argument #3...
  acceleration->set(baseline, k1, 5);                                                     // Setting kernel argument #4...
  acceleration_int->set(baseline, k1, 6);                                                     // Setting kernel argument #4...
  gravity->set(baseline, k1, 7);                                                          // Setting kernel argument #5...
  stiffness->set(baseline, k1, 8);                                                        // Setting kernel argument #6...
  resting->set(baseline, k1, 9);                                                          // Setting kernel argument #7...
  friction->set(baseline, k1, 10);                                                         // Setting kernel argument #8...
  mass->set(baseline, k1, 11);                                                             // Setting kernel argument #9...
  index_PR->set(baseline, k1, 12);                                                        // Setting kernel argument #11...
  index_PU->set(baseline, k1, 13);                                                        // Setting kernel argument #12...
  index_PL->set(baseline, k1, 14);                                                        // Setting kernel argument #13...
  index_PD->set(baseline, k1, 15);                                                        // Setting kernel argument #14...
  freedom->set(baseline, k1, 16);                                                         // Setting kernel argument #15...
  dt->set(baseline, k1,17);

  position->set(baseline, k2, 0);                                                         // Setting kernel argument #0...
  color->set(baseline, k2, 1);                                                           // Setting kernel argument #1...
  position_int->set(baseline, k2, 2);                                                         // Setting kernel argument #0...
  velocity->set(baseline, k2, 3);                                                         // Setting kernel argument #3...
  velocity_int->set(baseline, k2, 4);                                                          // Setting kernel argument #3...
  acceleration->set(baseline, k2, 5);                                                     // Setting kernel argument #4...
  acceleration_int->set(baseline, k2, 6);                                                     // Setting kernel argument #4...
  gravity->set(baseline, k2, 7);                                                          // Setting kernel argument #5...
  stiffness->set(baseline, k2, 8);                                                        // Setting kernel argument #6...
  resting->set(baseline, k2, 9);                                                          // Setting kernel argument #7...
  friction->set(baseline, k2, 10);                                                         // Setting kernel argument #8...
  mass->set(baseline, k2, 11);                                                             // Setting kernel argument #9...
  index_PR->set(baseline, k2, 12);                                                        // Setting kernel argument #11...
  index_PU->set(baseline, k2, 13);                                                        // Setting kernel argument #12...
  index_PL->set(baseline, k2, 14);                                                        // Setting kernel argument #13...
  index_PD->set(baseline, k2, 15);                                                        // Setting kernel argument #14...
  freedom->set(baseline, k2, 16);                                                         // Setting kernel argument #15...
  dt->set(baseline, k2, 17);

  // Thickness, volume density, Young's modulus, viscosity
  float h = 1e-2;
  float rho = 1e3;
  float E = 1e5;
  float mu = 700.0;

  // Model parameters (mass, gravity, stiffness, damping)
  float m = rho*h*DX*DY;
  float g = 10.0f;
  float k = E*h*DY/DX;
  float c = mu*h*DX*DY;

  // Time step
  dt->set_x(0, 0.8*sqrt(m/k));

  // Print info on time step (critical DT for stability)
  float cDT = sqrt(m/k);
  printf("Critical DT = %f\n", cDT);
  printf("Simulation DT = %f\n", dt->get_x(0));

  // Set initial time to zero
  simulation_time = 0.0f;
  time_step_number = 0;

  y = Y_MIN;

  for (j = 0; j < NODES_Y; j++)
  {
    x = X_MIN;

    for (i = 0; i < NODES_X; i++)
    {
      // Setting "x" initial position...
      position->set_x(i + NODES_Y*j, x);
      position->set_y(i + NODES_Y*j, y);
      position->set_z(i + NODES_Y*j, 0.0f);
      position->set_w(i + NODES_Y*j, 1.0f);

      gravity->set_x(i + NODES_Y*j, 0.0f);                                          // Setting "x" gravity...
      gravity->set_y(i + NODES_Y*j, 0.0f);                                          // Setting "y" gravity...
      gravity->set_z(i + NODES_Y*j, -g);                                         // Setting "z" gravity...
      gravity->set_w(i + NODES_Y*j, 1.0f);                                          // Setting "w" gravity...

      stiffness->set_x(i + NODES_Y*j, k);                                   // Setting "x" stiffness...
      stiffness->set_y(i + NODES_Y*j, k);                                   // Setting "y" stiffness...
      stiffness->set_z(i + NODES_Y*j, k);                                   // Setting "z" stiffness...
      stiffness->set_w(i + NODES_Y*j, 1.0f);                                        // Setting "w" stiffness...

      resting->set_x(i + NODES_Y*j, DX);                                            // Setting "x" resting position...
      resting->set_y(i + NODES_Y*j, DX);                                            // Setting "y" resting position...
      resting->set_z(i + NODES_Y*j, DX);                                            // Setting "z" resting position...
      resting->set_w(i + NODES_Y*j, 1.0f);                                          // Setting "w" resting position...

      friction->set_x(i + NODES_Y*j, c);                                        // Setting "x" friction...
      friction->set_y(i + NODES_Y*j, c);                                        // Setting "y" friction...
      friction->set_z(i + NODES_Y*j, c);                                        // Setting "z" friction...
      friction->set_w(i + NODES_Y*j, 1.0f);                                         // Setting "w" friction...

      mass->set_x(i + NODES_Y*j, m);                                             // Setting "x" mass...
      mass->set_y(i + NODES_Y*j, m);                                             // Setting "y" mass...
      mass->set_z(i + NODES_Y*j, m);                                             // Setting "z" mass...
      mass->set_w(i + NODES_Y*j, 1.0f);                                             // Setting "w" mass...

      color->set_r(i + NODES_Y*j, 1.0f);                                            // Setting "x" initial color...
      color->set_g(i + NODES_Y*j, 0.0f);                                            // Setting "y" initial color...
      color->set_b(i + NODES_Y*j, 0.0f);                                            // Setting "z" initial color...
      color->set_a(i + NODES_Y*j, 1.0f);                                            // Setting "w" initial color...

      freedom->set_x(i + NODES_Y*j, 1.0f);
      freedom->set_y(i + NODES_Y*j, 1.0f);
      freedom->set_z(i + NODES_Y*j, 1.0f);
      freedom->set_w(i + NODES_Y*j, 1.0f);

      if ((i != 0) && (i != (NODES_X - 1)) && (j != 0) && (j != (NODES_Y - 1)))   // When on bulk:
      {
        index_PR->set_x(i + NODES_Y*j, (i + 1)  + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j, i       + NODES_Y*(j + 1));
        index_PL->set_x(i + NODES_Y*j, (i - 1)  + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j, i       + NODES_Y*(j - 1));
      }

      else                                                                      // When on all borders:
      {
        gravity->set_x(i + NODES_Y*j, 0.0f);                                        // Setting "x" gravity...
        gravity->set_y(i + NODES_Y*j, 0.0f);                                        // Setting "y" gravity...
        gravity->set_z(i + NODES_Y*j, 0.0f);                                        // Setting "z" gravity...
        gravity->set_w(i + NODES_Y*j, 1.0f);                                        // Setting "w" gravity...

        freedom->set_x(i + NODES_Y*j, 0.0f);
        freedom->set_y(i + NODES_Y*j, 0.0f);
        freedom->set_z(i + NODES_Y*j, 0.0f);
        freedom->set_w(i + NODES_Y*j, 0.0f);
      }

      if ((i == 0) && (j != 0) && (j != (NODES_Y - 1)))                          // When on left border (excluding extremes):
      {
        index_PR->set_x(i + NODES_Y*j, (i + 1)  + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j, i       + NODES_Y*(j + 1));
        index_PL->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j,  i       + NODES_Y*(j - 1));
      }

      if ((i == (NODES_X - 1)) && (j != 0) && (j != (NODES_Y - 1)))               // When on right border (excluding extremes):
      {
        index_PR->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j, i + NODES_Y*(j + 1));
        index_PL->set_x(i + NODES_Y*j, (i - 1)  + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j, i       + NODES_Y*(j - 1));
      }

      if ((j == 0) && (i != 0) && (i != (NODES_X - 1)))                          // When on low border (excluding extremes):
      {
        index_PR->set_x(i + NODES_Y*j, (i + 1)  + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j, i       + NODES_Y*(j + 1));
        index_PL->set_x(i + NODES_Y*j, (i - 1)  + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j, i + NODES_Y*j);
      }

      if ((j == (NODES_Y - 1)) && (i != 0) && (i != (NODES_X - 1)))               // When on high border (excluding extremes):
      {
        index_PR->set_x(i + NODES_Y*j, (i + 1)  + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PL->set_x(i + NODES_Y*j, (i - 1)  + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j, i       + NODES_Y*(j - 1));
      }

      if ((i == 0) && (j == 0))                                                 // When on low left corner:
      {
        index_PR->set_x(i + NODES_Y*j, (i + 1)  + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j,  i       + NODES_Y*(j + 1));
        index_PL->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j, i + NODES_Y*j);
      }

      if ((i == (NODES_X - 1)) && (j == 0))                                      // When on low right corner:
      {
        index_PR->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j, i       + NODES_Y*(j + 1));
        index_PL->set_x(i + NODES_Y*j, (i - 1)  + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j, i + NODES_Y*j);
      }

      if ((i == 0) && (j == (NODES_Y - 1)))                                      // When on high left corner:
      {
        index_PR->set_x(i + NODES_Y*j, (i + 1)  + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PL->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j, i       + NODES_Y*(j - 1));
      }

      if ((i == (NODES_X - 1)) && (j == (NODES_Y - 1)))                           // When on high right corner:
      {
        index_PR->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PU->set_x(i + NODES_Y*j, i + NODES_Y*j);
        index_PL->set_x(i + NODES_Y*j, (i - 1)  + NODES_Y*j);
        index_PD->set_x(i + NODES_Y*j, i       + NODES_Y*(j - 1));
      }

      x += DX;
    }
    y += DY;
  }


  position->acquire_gl(q1);
  color->acquire_gl(q1);
  position->write(q1, 0);
  color->write(q1, 1);
  position->release_gl(q1);
  color->release_gl(q1);

  position_int->write(q1, 2);                                                     // Pushing kernel argument #0...
  velocity->write(q1, 3);                                                     // Pushing kernel argument #3...
  velocity_int->write(q1, 4);                                                     // Pushing kernel argument #3...
  acceleration->write(q1, 5);                                                 // Pushing kernel argument #4...
  acceleration_int->write(q1, 6);                                                 // Pushing kernel argument #4...
  gravity->write(q1, 7);                                                      // Pushing kernel argument #5...
  stiffness->write(q1, 8);                                                    // Pushing kernel argument #6...
  resting->write(q1, 9);                                                      // Pushing kernel argument #7...
  friction->write(q1, 10);                                                     // Pushing kernel argument #8...
  mass->write(q1, 11);                                                         // Pushing kernel argument #9...
  index_PR->write(q1, 12);                                                    // Pushing kernel argument #11...
  index_PU->write(q1, 13);                                                    // Pushing kernel argument #12...
  index_PL->write(q1, 14);                                                    // Pushing kernel argument #13...
  index_PD->write(q1, 15);                                                    // Pushing kernel argument #14...
  freedom->write(q1, 16);                                                     // Pushing kernel argument #15...
  dt->write(q1, 17);

  while (!gui->closed())                                                        // Opening window...
  {
    baseline->get_tic();                                                        // Getting "tic" [us]...

    gui->clear();                                                               // Clearing window...
    gui->poll_events();                                                         // Polling window events...

    position->acquire_gl(q1);
    color->acquire_gl(q1);

    k1->execute(q1, WAIT);

    k2->execute(q1, WAIT);

    position->release_gl(q1);
    color->release_gl(q1);

    gui->plot(position, color, STYLE_POINT);
    gui->refresh();                                                             // Refreshing window...

    // Update simulation time
    simulation_time += dt->x[0];
    time_step_number += 1;

    baseline->get_toc();                                                        // Getting "toc" [us]...
  }

  delete    baseline;
  delete    gui;
  delete    cl;

  delete position;
  delete position_int;
  delete color;
  delete velocity;
  delete velocity_int;
  delete acceleration;
  delete acceleration_int;
  delete gravity;
  delete stiffness;
  delete resting;
  delete friction;
  delete mass;
  delete index_PD;
  delete index_PL;
  delete index_PR;
  delete index_PU;
  delete dt;

  delete    q1;

  delete[]  k1_size;
  delete    k1;
  delete[]  k2_size;
  delete    k2;

  return 0;
}
