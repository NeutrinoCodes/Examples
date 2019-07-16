/// @file

// MESH:
#define XMIN        -1.0                                                        // XMIN spatial boundary [m].
#define XMAX        +1.0                                                        // XMAX spatial boundary [m].
#define YMIN        -1.0                                                        // YMIN spatial boundary [m].
#define YMAX        +1.0                                                        // YMAX spatial boundary [m].
#define NODES_X     100                                                         // Number of nodes in "X" direction [#].
#define NODES_Y     100                                                         // Number of nodes in "Y" direction [#].
#define NODES       NODES_X* NODES_Y                                            // Total number of nodes [#].
#define DX          (float)((XMAX - XMIN)/(NODES_X - 1))                        // DX mesh spatial size [m].
#define DY          (float)((YMAX - YMIN)/(NODES_Y - 1))                        // DY mesh spatial size [m].

// OPENGL:
#define INTEROP     true                                                        // "true" = use OpenGL-OpenCL interoperability.
#define GUI_SIZE_X  800                                                         // Window x-size [px].
#define GUI_SIZE_Y  600                                                         // Window y-size [px].
#define GUI_NAME    "neutrino 3.0"                                              // Window name.
//#define SHADER_HOME \
//  "/run/media/ezor/LINUX/BookhouseBoys/ezor/Neutrino/Code/shader"
#define SHADER_HOME \
  "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/ElasticCloth/Code/shader"
#define SHADER_VERT "voxel_vertex.vert"                                         // OpenGL vertex shader.
#define SHADER_GEOM "voxel_geometry.geom"                                       // OpenGL geometry shader.
#define SHADER_FRAG "voxel_fragment.frag"                                       // OpenGL fragment shader.

// OPENCL:
#define QUEUE_NUM   1                                                           // # of OpenCL queues [#].
#define KERNEL_NUM  2                                                           // # of OpenCL kernel [#].
#define KERNEL_SX   NODES                                                       // Dimension of OpenCL kernel (i-index).
#define KERNEL_SY   0                                                           // Dimension of OpenCL kernel (j-index).
#define KERNEL_SZ   0                                                           // Dimension of OpenCL kernel (k-index).
//#define KERNEL_HOME \
//  "/run/media/ezor/LINUX/BookhouseBoys/ezor/Neutrino/Code/kernel"               // OpenCL kernel header files directory.
#define KERNEL_HOME \
  "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/ElasticCloth/Code/kernel"
#define K1_FILE     "thekernel1.cl"                                             // OpenCL kernel.
#define K2_FILE     "thekernel2.cl"                                             // OpenCL kernel.

// INCLUDES:
#include "opengl.hpp"
#include "opencl.hpp"

int main ()
{
  neutrino* bas              = new neutrino ();                                 // Neutrino baseline.
  opengl*   gui              = new opengl ();                                   // OpenGL context.
  opencl*   ctx              = new opencl ();                                   // OpenCL context.
  shader*   S                = new shader ();                                   // OpenGL shader program.
  point*    P                = new point ();                                    // OpenGL point.
  color*    C                = new color ();                                    // OpenGL color.
  float1*   t                = new float1 ();                                   // Time [s].
  queue*    Q                = new queue ();                                    // OpenCL queue.
  kernel*   K1               = new kernel ();                                   // OpenCL kernel array.
  kernel*   K2               = new kernel ();                                   // OpenCL kernel array.
  size_t    i;                                                                  // "x" direction index.
  size_t    j;                                                                  // "y" direction index.

  point*    position         = new point ();                                    // Position.
  color*    color            = new color ();                                    // Particle color.
  float4*   velocity         = new float4 ();                                   // Velocity.
  float4*   acceleration     = new float4 ();                                   // Acceleration.

  float4*   position_int     = new float4 ();                                   // Position (intermediate).
  float4*   velocity_int     = new float4 ();                                   // Velocity (intermediate).
  float4*   acceleration_int = new float4 ();                                   // Acceleration (intermediate).

  float4*   gravity          = new float4 ();                                   // Gravity.
  float4*   stiffness        = new float4 ();                                   // Stiffness.
  float4*   resting          = new float4 ();                                   // Resting.
  float4*   friction         = new float4 ();                                   // Friction.
  float4*   mass             = new float4 ();                                   // Mass.

  int1*     index_PR         = new int1 ();                                     // Right particle.
  int1*     index_PU         = new int1 ();                                     // Up particle.
  int1*     index_PL         = new int1 ();                                     // Left particle.
  int1*     index_PD         = new int1 ();                                     // Down particle.

  float4*   freedom          = new float4 ();                                   // Freedom/constrain flag.

  float1*   dt               = new float1 ();                                   // Time step.
  float     simulation_time;                                                    // Simulation time.
  int       time_step_number;                                                   // Time step index.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// INITIALIZATION ///////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  bas->init (QUEUE_NUM, KERNEL_NUM, INTEROP);                                   // Initializing Neutrino baseline...
  gui->init (bas, GUI_SIZE_X, GUI_SIZE_Y, GUI_NAME);                            // Initializing OpenGL context...
  ctx->init (bas, gui, GPU);                                                    // Initializing OpenCL context...
  S->init (bas, SHADER_HOME, SHADER_VERT, SHADER_GEOM, SHADER_FRAG);            // Initializing OpenGL shader...
  position->init (NODES);                                                       // Initializing OpenGL point array...
  color->init (NODES);                                                          // Initializing OpenGL color array...
  position_int->init (NODES);
  velocity->init (NODES);
  velocity_int->init (NODES);
  acceleration->init (NODES);
  gravity->init (NODES);
  stiffness->init (NODES);
  resting->init (NODES);
  friction->init (NODES);
  mass->init (NODES);
  index_PR->init (NODES);
  index_PU->init (NODES);
  index_PL->init (NODES);
  index_PD->init (NODES);
  freedom->init (NODES);
  t->init (NODES);                                                              // Initializing time...
  Q->init (bas);                                                                // Initializing OpenCL queue...
  K1->init (bas, KERNEL_HOME, K1_FILE, KERNEL_SX, KERNEL_SY, KERNEL_SZ);        // Initializing OpenCL kernel K1...
  K2->init (bas, KERNEL_HOME, K2_FILE, KERNEL_SX, KERNEL_SY, KERNEL_SZ);        // Initializing OpenCL kernel K2...


  dt->init (baseline, 1);

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// SETTING OPENCL KERNEL ARGUMENTS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  K1->setarg (position, 0);                                                     // Setting kernel argument "0"...
  K1->setarg (color, 1);                                                        // Setting kernel argument "1"...
  K1->setarg (position_int, 2);
  K1->setarg (velocity, 3);
  K1->setarg (velocity_int, 4);
  K1->setarg (acceleration, 5);
  K1->setarg (acceleration_int, 6);
  K1->setarg (gravity, 7);
  K1->setarg (stiffness, 8);
  K1->setarg (resting, 9);
  K1->setarg (friction, 10);
  K1->setarg (mass, 11);
  K1->setarg (index_PR, 12);
  K1->setarg (index_PU, 13);
  K1->setarg (index_PL, 14);
  K1->setarg (index_PD, 15);
  K1->setarg (freedom, 16);
  K1->setarg (dt, 17);

  K2->setarg (position, 0);                                                     // Setting kernel argument "0"...
  K2->setarg (color, 1);                                                        // Setting kernel argument "1"...
  K2->setarg (position_int, 2);
  K2->setarg (velocity, 3);
  K2->setarg (velocity_int, 4);
  K2->setarg (acceleration, 5);
  K2->setarg (acceleration_int, 6);
  K2->setarg (gravity, 7);
  K2->setarg (stiffness, 8);
  K2->setarg (resting, 9);
  K2->setarg (friction, 10);
  K2->setarg (mass, 11);
  K2->setarg (index_PR, 12);
  K2->setarg (index_PU, 13);
  K2->setarg (index_PL, 14);
  K2->setarg (index_PD, 15);
  K2->setarg (freedom, 16);
  K2->setarg (dt, 17);

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// SETTING OPENCL DATA OBJECTS /////////////////////////
  ////////////////////////////////////////////////////////////////////////////////

  // Thickness, volume density, Young's modulus, viscosity
  float h   = 1e-2;
  float rho = 1e3;
  float E   = 1e5;
  float mu  = 700.0;

  // Model parameters (mass, gravity, stiffness, damping)
  float m   = rho*h*DX*DY;
  float g   = 10.0f;
  float k   = E*h*DY/DX;
  float c   = mu*h*DX*DY;

  dt->set_x (0, 0.8*sqrt (m/k));                                                // Setting time step...

  // Print info on time step (critical DT for stability)
  float cDT = sqrt (m/k);
  printf ("Critical DT = %f\n", cDT);
  printf ("Simulation DT = %f\n", dt->get_x (0));

  // Set initial time to zero
  simulation_time  = 0.0f;
  time_step_number = 0;

  for(j = 0; j < NODES_Y; j++)
  {
    for(i = 0; i < NODES_X; i++)
    {
      // Setting "x" initial position...
      position->data[i + NODES_X*j].x  = XMIN + i*DX;
      position->data[i + NODES_X*j].y  = YMIN + j*DY;
      position->data[i + NODES_X*j].z  = 0.0;
      position->data[i + NODES_X*j].w  = 1.0;

      gravity->data[i + NODES_X*j].x   = 0.0;                                   // Setting "x" gravity...
      gravity->data[i + NODES_X*j].y   = 0.0;                                   // Setting "y" gravity...
      gravity->data[i + NODES_X*j].z   = -g;                                    // Setting "z" gravity...
      gravity->data[i + NODES_X*j].w   = 1.0;                                   // Setting "w" gravity...

      stiffness->data[i + NODES_X*j].x = k;                                     // Setting "x" stiffness...
      stiffness->data[i + NODES_X*j].y = k;                                     // Setting "y" stiffness...
      stiffness->data[i + NODES_X*j].z = k;                                     // Setting "z" stiffness...
      stiffness->data[i + NODES_X*j].w = 1.0;                                   // Setting "w" stiffness...

      resting->data[i + NODES_X*j].x   = DX;                                    // Setting "x" resting position...
      resting->data[i + NODES_X*j].y   = DX;                                    // Setting "y" resting position...
      resting->data[i + NODES_X*j].z   = DX;                                    // Setting "z" resting position...
      resting->data[i + NODES_X*j].w   = 1.0;                                   // Setting "w" resting position...

      friction->data[i + NODES_X*j].x  = c;                                     // Setting "x" friction...
      friction->data[i + NODES_X*j].y  = c;                                     // Setting "y" friction...
      friction->data[i + NODES_X*j].z  = c;                                     // Setting "z" friction...
      friction->data[i + NODES_X*j].w  = 1.0;                                   // Setting "w" friction...

      mass->data[i + NODES_X*j].x      = m;                                     // Setting "x" mass...
      mass->data[i + NODES_X*j].y      = m;                                     // Setting "y" mass...
      mass->data[i + NODES_X*j].z      = m;                                     // Setting "z" mass...
      mass->data[i + NODES_X*j].w      = 1.0;                                   // Setting "w" mass...

      color->data[i + NODES_X*j].x     = 1.0;                                   // Setting "x" initial color...
      color->data[i + NODES_X*j].y     = 0.0;                                   // Setting "y" initial color...
      color->data[i + NODES_X*j].z     = 0.0;                                   // Setting "z" initial color...
      color->data[i + NODES_X*j].w     = 1.0;                                   // Setting "w" initial color...

      freedom->data[i + NODES_X*j].x   = 1.0;
      freedom->data[i + NODES_X*j].y   = 1.0;
      freedom->data[i + NODES_X*j].z   = 1.0;
      freedom->data[i + NODES_X*j].w   = 1.0;

      if((i != 0) && (i != (NODES_X - 1)) && (j != 0) && (j != (NODES_Y - 1)))  // When on bulk:
      {
        index_PR->set_x (i + NODES_X*j, (i + 1) + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*(j + 1));
        index_PL->set_x (i + NODES_X*j, (i - 1) + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*(j - 1));
      }

      else                                                                      // When on all borders:
      {
        gravity->set_x (i + NODES_X*j, 0.0f);                                   // Setting "x" gravity...
        gravity->set_y (i + NODES_X*j, 0.0f);                                   // Setting "y" gravity...
        gravity->set_z (i + NODES_X*j, 0.0f);                                   // Setting "z" gravity...
        gravity->set_w (i + NODES_X*j, 1.0f);                                   // Setting "w" gravity...

        freedom->set_x (i + NODES_X*j, 0.0f);
        freedom->set_y (i + NODES_X*j, 0.0f);
        freedom->set_z (i + NODES_X*j, 0.0f);
        freedom->set_w (i + NODES_X*j, 0.0f);
      }

      if((i == 0) && (j != 0) && (j != (NODES_Y - 1)))                          // When on left border (excluding extremes):
      {
        index_PR->set_x (i + NODES_X*j, (i + 1) + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*(j + 1));
        index_PL->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*(j - 1));
      }

      if((i == (NODES_X - 1)) && (j != 0) && (j != (NODES_Y - 1)))              // When on right border (excluding extremes):
      {
        index_PR->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*(j + 1));
        index_PL->set_x (i + NODES_X*j, (i - 1) + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*(j - 1));
      }

      if((j == 0) && (i != 0) && (i != (NODES_X - 1)))                          // When on bottom border (excluding extremes):
      {
        index_PR->set_x (i + NODES_X*j, (i + 1) + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*(j + 1));
        index_PL->set_x (i + NODES_X*j, (i - 1) + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*j);
      }

      if((j == (NODES_Y - 1)) && (i != 0) && (i != (NODES_X - 1)))              // When on high border (excluding extremes):
      {
        index_PR->set_x (i + NODES_X*j, (i + 1) + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PL->set_x (i + NODES_X*j, (i - 1) + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*(j - 1));
      }

      if((i == 0) && (j == 0))                                                  // When on bottom left corner:
      {
        index_PR->set_x (i + NODES_X*j, (i + 1) + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*(j + 1));
        index_PL->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*j);
      }

      if((i == (NODES_X - 1)) && (j == 0))                                      // When on bottom right corner:
      {
        index_PR->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*(j + 1));
        index_PL->set_x (i + NODES_X*j, (i - 1) + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*j);
      }

      if((i == 0) && (j == (NODES_Y - 1)))                                      // When on top left corner:
      {
        index_PR->set_x (i + NODES_X*j, (i + 1) + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PL->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*(j - 1));
      }

      if((i == (NODES_X - 1)) && (j == (NODES_Y - 1)))                          // When on top right corner:
      {
        index_PR->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PU->set_x (i + NODES_X*j, i + NODES_X*j);
        index_PL->set_x (i + NODES_X*j, (i - 1) + NODES_X*j);
        index_PD->set_x (i + NODES_X*j, i + NODES_X*(j - 1));
      }

    }

  }

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// PUSHING OPENCL KERNEL ARGUMENTS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  position->acquire_gl (Q[0],0);
  position->push (Q[0], 0);
  position->release_gl (Q[0], 0);
  color->acquire_gl (Q[0], 1);
  color->push (Q[0], 1);
  color->release_gl (Q[0], 1);

  position_int->push (Q[0], 2);
  velocity->push (Q[0], 3);
  velocity_int->push (Q[0], 4);
  acceleration->push (Q[0], 5);
  acceleration_int->push (Q[0], 6);
  gravity->push (Q[0], 7);
  stiffness->push (Q[0], 8);
  resting->push (Q[0], 9);
  friction->push (Q[0], 10);
  mass->push (Q[0], 11);
  index_PR->push (Q[0], 12);
  index_PU->push (Q[0], 13);
  index_PL->push (Q[0], 14);
  index_PD->push (Q[0], 15);
  freedom->push (Q[0], 16);
  dt->push (Q[0], 17);

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// MAIN LOOP ////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  while(!gui->closed ())                                                        // Opening window...
  {
    baseline->get_tic ();                                                       // Getting "tic" [us]...

    gui->clear ();                                                              // Clearing window...
    gui->poll_events ();                                                        // Polling window events...

    position->acquire_gl (Q[0], 0);
    color->acquire_gl (Q[0], 1);

    K[0]->execute (Q[0], WAIT);

    K[1]->execute (Q[0], WAIT);

    position->release_gl (Q[0], 0);
    color->release_gl (Q[0], 1);

    gui->plot (position, color, STYLE_POINT);
    gui->refresh ();                                                            // Refreshing window...

    // Update simulation time
    simulation_time  += dt->get_x (0);
    time_step_number += 1;

    baseline->get_toc ();                                                       // Getting "toc" [us]...
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
