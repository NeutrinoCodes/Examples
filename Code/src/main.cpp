/// @file

#define SIZE_WINDOW_X  800                                                      // Window x-size [px].
#define SIZE_WINDOW_Y  600                                                      // Window y-size [px].
#define WINDOW_NAME    "cloth 2.0"                                              // Window name.

#define QUEUE_NUM      1

#define KERNEL_NUM     2
#define KERNEL_DIM     1

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

  queue**   Q               = new queue*[QUEUE_NUM];                            // OpenCL queue.

  size_t**  K_size          = new size_t*[KERNEL_NUM];                          // OpenCL kernel dimensions array...
  kernel**  K               = new kernel*[KERNEL_NUM];                          // OpenCL kernel array...

  point4* position          = new point4();                                     // Position.
  color4* color             = new color4();                                     // Particle color.
  float4* velocity          = new float4();                                     // Velocity.
  float4* acceleration      = new float4();                                     // Acceleration.

  float4* position_int      = new float4();                                     // Position (intermediate).
  float4* velocity_int      = new float4();                                     // Velocity (intermediate).
  float4* acceleration_int  = new float4();                                     // Acceleration (intermediate).

  float4* gravity           = new float4();                                     // Gravity.
  float4* stiffness         = new float4();                                     // Stiffness.
  float4* resting           = new float4();                                     // Resting.
  float4* friction          = new float4();                                     // Friction.
  float4* mass              = new float4();                                     // Mass.

  int1* index_PR            = new int1();                                       // Right particle.
  int1* index_PU            = new int1();                                       // Up particle.
  int1* index_PL            = new int1();                                       // Left particle.
  int1* index_PD            = new int1();                                       // Down particle.

  float4* freedom           = new float4();                                     // Freedom/constrain flag.

  float1* dt                = new float1();                                     // Time step.
  float   simulation_time;                                                      // Simulation time.
  int     time_step_number;                                                     // Time step index.

  size_t    i;
  size_t    j;
  float x;
  float y;

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////// INITIALIZING NEUTRINO, OPENGL and OPENCL //////////////////
  ////////////////////////////////////////////////////////////////////////////////
  baseline  ->init(QUEUE_NUM, KERNEL_NUM);                                      // Initializing neutrino...
  gui       ->init(baseline, SIZE_WINDOW_X, SIZE_WINDOW_Y, WINDOW_NAME);        // Initializing window...
  cl        ->init(baseline, gui->glfw_window, GPU);                            // Initializing OpenCL context...

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////////////// INITIALIZING OPENCL QUEUES /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  for(i = 0; i < QUEUE_NUM; i++)                                                // For each OpenCL queue:
  {
    Q[i]                    = new queue();                                      // OpenCL queue.
    Q[i]    ->init(baseline);                                                   // Initializing OpenCL queue...
  }

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// INITIALIZING OPENCL KERNELS /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  for(j = 0; j < KERNEL_NUM; j++)                                               // For each OpenCL kernel:
  {
    K_size[j]               = new size_t[KERNEL_DIM];                           // OpenCL kernel dimensions.

    for (i = 0; i < KERNEL_DIM; i++)                                            // Setting all kernel sizes...
    {
      K_size[j][i] = NODES;                                                     // Setting size of each kernel dimension...
    }

  }

  K[0]    = new kernel();                                                       // OpenCL kernel.
  K[0]    ->init(
                    baseline,                                                   // Neutrino baseline.
                    "../../kernel/thekernel1.cl",                               // Kernel file name.
                    K_size[0],                                                  // Kernel dimensions array.
                    KERNEL_DIM                                                  // Kernel dimension.
                  );

  K[1]    = new kernel();                                                       // OpenCL kernel.
  K[1]    ->init(
                    baseline,                                                   // Neutrino baseline.
                    "../../kernel/thekernel2.cl",                               // Kernel file name.
                    K_size[1],                                                  // Kernel dimensions array.
                    KERNEL_DIM                                                  // Kernel dimension.
                  );

  ////////////////////////////////////////////////////////////////////////////////
  /////////////////////// INITIALIZING OPENCL DATA OBJECTS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  position->init(baseline, NODES);
  color->init(baseline, NODES);
  position_int->init(baseline, NODES);
  velocity->init(baseline, NODES);
  velocity_int->init(baseline, NODES);
  acceleration->init(baseline, NODES);
  acceleration_int->init(baseline, NODES);
  gravity->init(baseline, NODES);
  stiffness->init(baseline, NODES);
  resting->init(baseline, NODES);
  friction->init(baseline, NODES);
  mass->init(baseline, NODES);
  index_PR->init(baseline, NODES);
  index_PU->init(baseline, NODES);
  index_PL->init(baseline, NODES);
  index_PD->init(baseline, NODES);
  freedom->init(baseline, NODES);
  dt->init(baseline, 1);

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// SETTING OPENCL KERNEL ARGUMENTS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  position->set_arg(K[0], 0);
  color->set_arg(K[0], 1);
  position_int->set_arg(K[0], 2);
  velocity->set_arg(K[0], 3);
  velocity_int->set_arg(K[0], 4);
  acceleration->set_arg(K[0], 5);
  acceleration_int->set_arg(K[0], 6);
  gravity->set_arg(K[0], 7);
  stiffness->set_arg(K[0], 8);
  resting->set_arg(K[0], 9);
  friction->set_arg(K[0], 10);
  mass->set_arg(K[0], 11);
  index_PR->set_arg(K[0], 12);
  index_PU->set_arg(K[0], 13);
  index_PL->set_arg(K[0], 14);
  index_PD->set_arg(K[0], 15);
  freedom->set_arg(K[0], 16);
  dt->set_arg(K[0], 17);

  position->set_arg(K[1], 0);
  color->set_arg(K[1], 1);
  position_int->set_arg(K[1], 2);
  velocity->set_arg(K[1], 3);
  velocity_int->set_arg(K[1], 4);
  acceleration->set_arg(K[1], 5);
  acceleration_int->set_arg(K[1], 6);
  gravity->set_arg(K[1], 7);
  stiffness->set_arg(K[1], 8);
  resting->set_arg(K[1], 9);
  friction->set_arg(K[1], 10);
  mass->set_arg(K[1], 11);
  index_PR->set_arg(K[1], 12);
  index_PU->set_arg(K[1], 13);
  index_PL->set_arg(K[1], 14);
  index_PD->set_arg(K[1], 15);
  freedom->set_arg(K[1], 16);
  dt->set_arg(K[1], 17);

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// SETTING OPENCL DATA OBJECTS /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////

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

  dt->set_x(0, 0.8*sqrt(m/k));                                                  // Setting time step...

  // Print info on time step (critical DT for stability)
  float cDT = sqrt(m/k);
  printf("Critical DT = %f\n", cDT);
  printf("Simulation DT = %f\n", dt->get_x(0));

  // Set initial time to zero
  simulation_time = 0.0f;
  time_step_number = 0;

  y = YMIN;

  for (j = 0; j < NODES_Y; j++)
  {
    x = XMIN;

    for (i = 0; i < NODES_X; i++)
    {
      // Setting "x" initial position...
      position->set_x(i + NODES_X*j, XMIN + i*DX);
      position->set_y(i + NODES_X*j, YMIN + j*DY);
      position->set_z(i + NODES_X*j, 0.0f);
      position->set_w(i + NODES_X*j, 1.0f);

      gravity->set_x(i + NODES_X*j, 0.0f);                                      // Setting "x" gravity...
      gravity->set_y(i + NODES_X*j, 0.0f);                                      // Setting "y" gravity...
      gravity->set_z(i + NODES_X*j, -g);                                        // Setting "z" gravity...
      gravity->set_w(i + NODES_X*j, 1.0f);                                      // Setting "w" gravity...

      stiffness->set_x(i + NODES_X*j, k);                                       // Setting "x" stiffness...
      stiffness->set_y(i + NODES_X*j, k);                                       // Setting "y" stiffness...
      stiffness->set_z(i + NODES_X*j, k);                                       // Setting "z" stiffness...
      stiffness->set_w(i + NODES_X*j, 1.0f);                                    // Setting "w" stiffness...

      resting->set_x(i + NODES_X*j, DX);                                        // Setting "x" resting position...
      resting->set_y(i + NODES_X*j, DY);                                        // Setting "y" resting position...
      resting->set_z(i + NODES_X*j, 0.0f);                                        // Setting "z" resting position...
      resting->set_w(i + NODES_X*j, 1.0f);                                      // Setting "w" resting position...

      friction->set_x(i + NODES_X*j, c);                                        // Setting "x" friction...
      friction->set_y(i + NODES_X*j, c);                                        // Setting "y" friction...
      friction->set_z(i + NODES_X*j, c);                                        // Setting "z" friction...
      friction->set_w(i + NODES_X*j, 1.0f);                                     // Setting "w" friction...

      mass->set_x(i + NODES_X*j, m);                                            // Setting "x" mass...
      mass->set_y(i + NODES_X*j, m);                                            // Setting "y" mass...
      mass->set_z(i + NODES_X*j, m);                                            // Setting "z" mass...
      mass->set_w(i + NODES_X*j, 1.0f);                                         // Setting "w" mass...

      color->set_r(i + NODES_X*j, 1.0f);                                        // Setting "x" initial color...
      color->set_g(i + NODES_X*j, 0.0f);                                        // Setting "y" initial color...
      color->set_b(i + NODES_X*j, 0.0f);                                        // Setting "z" initial color...
      color->set_a(i + NODES_X*j, 1.0f);                                        // Setting "w" initial color...

      freedom->set_x(i + NODES_X*j, 1.0f);
      freedom->set_y(i + NODES_X*j, 1.0f);
      freedom->set_z(i + NODES_X*j, 1.0f);
      freedom->set_w(i + NODES_X*j, 1.0f);

      if ((i != 0) && (i != (NODES_X - 1)) && (j != 0) && (j != (NODES_Y - 1))) // When on bulk:
      {
        index_PR->set_x(i + NODES_X*j, (i + 1)  + NODES_X*j);
        index_PU->set_x(i + NODES_X*j, i       + NODES_X*(j + 1));
        index_PL->set_x(i + NODES_X*j, (i - 1)  + NODES_X*j);
        index_PD->set_x(i + NODES_X*j, i       + NODES_X*(j - 1));
      }

      else                                                                      // When on all borders:
      {
        gravity->set_x(i + NODES_X*j, 0.0f);                                    // Setting "x" gravity...
        gravity->set_y(i + NODES_X*j, 0.0f);                                    // Setting "y" gravity...
        gravity->set_z(i + NODES_X*j, 0.0f);                                    // Setting "z" gravity...
        gravity->set_w(i + NODES_X*j, 1.0f);                                    // Setting "w" gravity...

        freedom->set_x(i + NODES_X*j, 0.0f);
        freedom->set_y(i + NODES_X*j, 0.0f);
        freedom->set_z(i + NODES_X*j, 0.0f);
        freedom->set_w(i + NODES_X*j, 0.0f);
      }

      if ((i == 0) && (j != 0) && (j != (NODES_Y - 1)))                         // When on left border (excluding extremes):
      {
        index_PR->set_x(i + NODES_X*j, (i + 1)  + NODES_X*j);
        index_PU->set_x(i + NODES_X*j, i       + NODES_X*(j + 1));
        index_PL->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PD->set_x(i + NODES_X*j,  i       + NODES_X*(j - 1));
      }

      if ((i == (NODES_X - 1)) && (j != 0) && (j != (NODES_Y - 1)))             // When on right border (excluding extremes):
      {
        index_PR->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PU->set_x(i + NODES_X*j, i + NODES_X*(j + 1));
        index_PL->set_x(i + NODES_X*j, (i - 1)  + NODES_X*j);
        index_PD->set_x(i + NODES_X*j, i       + NODES_X*(j - 1));
      }

      if ((j == 0) && (i != 0) && (i != (NODES_X - 1)))                         // When on bottom border (excluding extremes):
      {
        index_PR->set_x(i + NODES_X*j, (i + 1)  + NODES_X*j);
        index_PU->set_x(i + NODES_X*j, i       + NODES_X*(j + 1));
        index_PL->set_x(i + NODES_X*j, (i - 1)  + NODES_X*j);
        index_PD->set_x(i + NODES_X*j, i + NODES_X*j);
      }

      if ((j == (NODES_Y - 1)) && (i != 0) && (i != (NODES_X - 1)))               // When on high border (excluding extremes):
      {
        index_PR->set_x(i + NODES_X*j, (i + 1)  + NODES_X*j);
        index_PU->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PL->set_x(i + NODES_X*j, (i - 1)  + NODES_X*j);
        index_PD->set_x(i + NODES_X*j, i       + NODES_X*(j - 1));
      }

      if ((i == 0) && (j == 0))                                                 // When on bottom left corner:
      {
        index_PR->set_x(i + NODES_X*j, (i + 1)  + NODES_X*j);
        index_PU->set_x(i + NODES_X*j,  i       + NODES_X*(j + 1));
        index_PL->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PD->set_x(i + NODES_X*j, i + NODES_X*j);
      }

      if ((i == (NODES_X - 1)) && (j == 0))                                     // When on bottom right corner:
      {
        index_PR->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PU->set_x(i + NODES_X*j, i       + NODES_X*(j + 1));
        index_PL->set_x(i + NODES_X*j, (i - 1)  + NODES_X*j);
        index_PD->set_x(i + NODES_X*j, i + NODES_X*j);
      }

      if ((i == 0) && (j == (NODES_Y - 1)))                                     // When on top left corner:
      {
        index_PR->set_x(i + NODES_X*j, (i + 1)  + NODES_X*j);
        index_PU->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PL->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PD->set_x(i + NODES_X*j, i       + NODES_X*(j - 1));
      }

      if ((i == (NODES_X - 1)) && (j == (NODES_Y - 1)))                         // When on top right corner:
      {
        index_PR->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PU->set_x(i + NODES_X*j, i + NODES_X*j);
        index_PL->set_x(i + NODES_X*j, (i - 1)  + NODES_X*j);
        index_PD->set_x(i + NODES_X*j, i       + NODES_X*(j - 1));
      }

      x += DX;
    }
    y += DY;
  }

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// PUSHING OPENCL KERNEL ARGUMENTS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  position          ->acquire_gl(Q[0],0);
  position          ->push(Q[0], 0);
  position          ->release_gl(Q[0], 0);
  color             ->acquire_gl(Q[0], 1);
  color             ->push(Q[0], 1);
  color             ->release_gl(Q[0], 1);

  position_int      ->push(Q[0], 2);
  velocity          ->push(Q[0], 3);
  velocity_int      ->push(Q[0], 4);
  acceleration      ->push(Q[0], 5);
  acceleration_int  ->push(Q[0], 6);
  gravity           ->push(Q[0], 7);
  stiffness         ->push(Q[0], 8);
  resting           ->push(Q[0], 9);
  friction          ->push(Q[0], 10);
  mass              ->push(Q[0], 11);
  index_PR          ->push(Q[0], 12);
  index_PU          ->push(Q[0], 13);
  index_PL          ->push(Q[0], 14);
  index_PD          ->push(Q[0], 15);
  freedom           ->push(Q[0], 16);
  dt                ->push(Q[0], 17);

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// MAIN LOOP ////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  while (!gui->closed())                                                        // Opening window...
  {
    baseline  ->get_tic();                                                      // Getting "tic" [us]...

    gui       ->clear();                                                        // Clearing window...
    gui       ->poll_events();                                                  // Polling window events...

    position  ->acquire_gl(Q[0], 0);
    color     ->acquire_gl(Q[0], 1);

    K[0]      ->execute(Q[0], WAIT);

    K[1]      ->execute(Q[0], WAIT);

    position  ->release_gl(Q[0], 0);
    color     ->release_gl(Q[0], 1);

    gui       ->plot(position, color, STYLE_POINT);
    gui       ->refresh();                                                      // Refreshing window...

    // Update simulation time
    simulation_time += dt->get_x(0);
    time_step_number += 1;

    baseline  ->get_toc();                                                      // Getting "toc" [us]...
  }

  delete    baseline;
  delete    gui;
  delete    cl;

  delete    position;
  delete    position_int;
  delete    color;
  delete    velocity;
  delete    velocity_int;
  delete    acceleration;
  delete    acceleration_int;
  delete    gravity;
  delete    stiffness;
  delete    resting;
  delete    friction;
  delete    mass;
  delete    index_PD;
  delete    index_PL;
  delete    index_PR;
  delete    index_PU;
  delete    freedom;
  delete    dt;

  delete[]  Q;
  delete[]  K;
  delete[]  K_size;

  return 0;
}
