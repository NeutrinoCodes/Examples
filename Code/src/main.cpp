/// @file

// OPENGL:
#define INTEROP     true                                                        // "true" = use OpenGL-OpenCL interoperability.
#define GUI_SX      800                                                         // Window x-size [px].
#define GUI_SY      600                                                         // Window y-size [px].
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
#define KERNEL_F1   "thekernel1.cl"                                             // OpenCL kernel.
#define KERNEL_F2   "thekernel2.cl"                                             // OpenCL kernel.

// INCLUDES:
#include "opengl.hpp"
#include "opencl.hpp"

int main ()
{
  // MESH:
  float     x_min            = -1.0;                                            // "x_min" spatial boundary [m].
  float     x_max            = +1.0;                                            // "x_max" spatial boundary [m].
  float     y_min            = -1.0;                                            // "y_min" spatial boundary [m].
  float     y_max            = +1.0;                                            // "y_max" spatial boundary [m].
  int       nodes_x          = 100;                                             // # of nodes in "X" direction [#].
  int       nodes_y          = 100;                                             // # of nodes in "Y" direction [#].
  int       nodes            = nodes_x*nodes_y;                                 // Total # of nodes [#].
  float     dx               = (x_max - x_min)/(nodes_x - 1);                   // DX mesh spatial size [m].
  float     dy               = (y_max - y_min)/(nodes_y - 1);                   // DY mesh spatial size [m].
  size_t    i;                                                                  // "x" direction index [#].
  size_t    j;                                                                  // "y" direction index [#].
  size_t    gid;                                                                // Global index [#].
  size_t    border_L;
  size_t    border_R;
  size_t    border_D;
  size_t    border_U;

  // SIMULATION PARAMETERS:
  float     h                = 0.01;                                            // Cloth's thickness [m].
  float     rho              = 1000.0;                                          // Cloth's mass density [kg/m^3].
  float     E                = 100000.0;                                        // Cloth's Young modulus [kg/(m*s^2)].
  float     mu               = 700.0;                                           // Cloth's viscosity [Pa*s].
  float     m                = rho*h*dx*dy;                                     // Cloth's mass [kg].
  float     g                = 9.81;                                            // External gravity field [m/s^2].
  float     k                = E*h*dy/dx;                                       // Cloth's elastic constant [kg/s^2].
  float     C                = mu*h*dx*dy;                                      // Cloth's damping [kg*s*m].
  float     dt_critical      = sqrt (m/k);                                      // Critical time step [s].
  float     dt_simulation    = 0.8* dt_critical;                                // Simulation time step [s].

  // NEUTRINO:
  neutrino* bas              = new neutrino ();                                 // Neutrino baseline.
  opengl*   gui              = new opengl ();                                   // OpenGL context.
  opencl*   ctx              = new opencl ();                                   // OpenCL context.
  shader*   S                = new shader ();                                   // OpenGL shader program.
  queue*    Q                = new queue ();                                    // OpenCL queue.
  kernel*   K1               = new kernel ();                                   // OpenCL kernel array.
  kernel*   K2               = new kernel ();                                   // OpenCL kernel array.

  // NODE KINEMATICS:
  point*    voxel_point      = new point ();                                    // Voxel point position.
  color*    voxel_color      = new color ();                                    // Voxel color.
  float4*   velocity         = new float4 ();                                   // Velocity.
  float4*   acceleration     = new float4 ();                                   // Acceleration.

  // NODE TEMPORARY KINEMATICS:
  float4*   position_int     = new float4 ();                                   // Position (intermediate).
  float4*   velocity_int     = new float4 ();                                   // Velocity (intermediate).
  float4*   acceleration_int = new float4 ();                                   // Acceleration (intermediate).

  // NODE DYNAMICS:
  float4*   gravity          = new float4 ();                                   // Gravity.
  float4*   stiffness        = new float4 ();                                   // Stiffness.
  float4*   resting          = new float4 ();                                   // Resting.
  float4*   friction         = new float4 ();                                   // Friction.
  float4*   mass             = new float4 ();                                   // Mass.

  // MESH CONNECTIVITY:
  int1*     index_PR         = new int1 ();                                     // Right neighbour index [#].
  int1*     index_PU         = new int1 ();                                     // Up neighbour index [#].
  int1*     index_PL         = new int1 ();                                     // Left neighbour index [#].
  int1*     index_PD         = new int1 ();                                     // Down neighbour index [#].

  float4*   freedom          = new float4 ();                                   // Freedom/constrain flag.
  float1*   dt               = new float1 ();                                   // Time step [s].

  float     simulation_time;                                                    // Simulation time.
  int       time_step_number;                                                   // Time step index.

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// INITIALIZATION ///////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  bas->init (QUEUE_NUM, KERNEL_NUM, INTEROP);                                   // Initializing Neutrino baseline...
  gui->init (bas, GUI_SX, GUI_SY, GUI_NAME);                                    // Initializing OpenGL context...
  ctx->init (bas, gui, NU_GPU);                                                 // Initializing OpenCL context...
  S->init (bas, SHADER_HOME, SHADER_VERT, SHADER_GEOM, SHADER_FRAG);            // Initializing OpenGL shader...
  Q->init (bas);                                                                // Initializing OpenCL queue...
  K1->init (bas, KERNEL_HOME, KERNEL_F1, KERNEL_SX, KERNEL_SY, KERNEL_SZ);      // Initializing OpenCL kernel K1...
  K2->init (bas, KERNEL_HOME, KERNEL_F2, KERNEL_SX, KERNEL_SY, KERNEL_SZ);      // Initializing OpenCL kernel K2...

  voxel_point->init (nodes);                                                    // Initializing OpenGL point array...
  voxel_color->init (nodes);                                                    // Initializing OpenGL color array...
  velocity->init (nodes);
  acceleration->init (nodes);

  position_int->init (nodes);
  velocity_int->init (nodes);
  acceleration_int->init (nodes);

  gravity->init (nodes);
  stiffness->init (nodes);
  resting->init (nodes);
  friction->init (nodes);
  mass->init (nodes);

  index_PR->init (nodes);
  index_PU->init (nodes);
  index_PL->init (nodes);
  index_PD->init (nodes);

  freedom->init (nodes);
  dt->init (nodes);

  simulation_time  = 0.0;
  time_step_number = 0;

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// SETTING OPENCL KERNEL ARGUMENTS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  K1->setarg (voxel_point, 0);                                                  // Setting kernel argument "0"...
  K1->setarg (voxel_color, 1);                                                  // Setting kernel argument "1"...
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

  K2->setarg (voxel_point, 0);                                                  // Setting kernel argument "0"...
  K2->setarg (voxel_color, 1);                                                  // Setting kernel argument "1"...
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

  printf ("Critical time step = %f [s]\n", dt_critical);
  printf ("Simulation time step = %f [s]\n", dt_simulation);

  voxel_point->name = "voxel_center";                                           // Setting variable name for OpenGL shader...
  voxel_color->name = "voxel_color";                                            // Setting variable name for OpenGL shader...

  for(j = 0; j < nodes_y; j++)
  {
    for(i = 0; i < nodes_y; i++)
    {
      // Computing global index:
      gid                      = i + nodes_x*j;

      // Setting "x" initial position...
      voxel_point->data[gid].x = x_min + i*dx;
      voxel_point->data[gid].y = y_min + j*dy;
      voxel_point->data[gid].z = 0.0;
      voxel_point->data[gid].w = 1.0;

      gravity->data[gid].x     = 0.0;                                           // Setting "x" gravity...
      gravity->data[gid].y     = 0.0;                                           // Setting "y" gravity...
      gravity->data[gid].z     = -g;                                            // Setting "z" gravity...
      gravity->data[gid].w     = 1.0;                                           // Setting "w" gravity...

      stiffness->data[gid].x   = k;                                             // Setting "x" stiffness...
      stiffness->data[gid].y   = k;                                             // Setting "y" stiffness...
      stiffness->data[gid].z   = k;                                             // Setting "z" stiffness...
      stiffness->data[gid].w   = 1.0;                                           // Setting "w" stiffness...

      resting->data[gid].x     = dx;                                            // Setting "x" resting position...
      resting->data[gid].y     = dx;                                            // Setting "y" resting position...
      resting->data[gid].z     = dx;                                            // Setting "z" resting position...
      resting->data[gid].w     = 1.0;                                           // Setting "w" resting position...

      friction->data[gid].x    = C;                                             // Setting "x" friction...
      friction->data[gid].y    = C;                                             // Setting "y" friction...
      friction->data[gid].z    = C;                                             // Setting "z" friction...
      friction->data[gid].w    = 1.0;                                           // Setting "w" friction...

      mass->data[gid].x        = m;                                             // Setting "x" mass...
      mass->data[gid].y        = m;                                             // Setting "y" mass...
      mass->data[gid].z        = m;                                             // Setting "z" mass...
      mass->data[gid].w        = 1.0;                                           // Setting "w" mass...

      voxel_color->data[gid].r = 1.0;                                           // Setting "x" initial color...
      voxel_color->data[gid].g = 0.0;                                           // Setting "y" initial color...
      voxel_color->data[gid].b = 0.0;                                           // Setting "z" initial color...
      voxel_color->data[gid].a = 1.0;                                           // Setting "w" initial color...

      freedom->data[gid].x     = 1.0;                                           // Setting "x" freedom...
      freedom->data[gid].y     = 1.0;                                           // Setting "y" freedom...
      freedom->data[gid].z     = 1.0;                                           // Setting "z" freedom...
      freedom->data[gid].w     = 1.0;                                           // Setting "w" freedom...

      dt->data[gid]            = DT;                                            // Setting time step...

      if((i != 0) && (i != (NODES_X - 1)) && (j != 0) && (j != (NODES_Y - 1)))  // When on bulk:
      {
        index_PR->data[gid] = (i + 1) + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*(j + 1);
        index_PL->data[gid] = (i - 1) + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*(j - 1);
      }

      else                                                                      // When on all borders:
      {
        gravity->data[gid].x = 0.0;                                             // Setting "x" gravity...
        gravity->data[gid].y = 0.0;                                             // Setting "y" gravity...
        gravity->data[gid].z = 0.0;                                             // Setting "z" gravity...
        gravity->data[gid].w = 1.0;                                             // Setting "w" gravity...

        freedom->data[gid].x = 0.0;
        freedom->data[gid].y = 0.0;
        freedom->data[gid].z = 0.0;
        freedom->data[gid].w = 0.0;
      }

      if((i == 0) && (j != 0) && (j != (NODES_Y - 1)))                          // When on left border (excluding extremes):
      {
        index_PR->data[gid] = (i + 1) + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*(j + 1);
        index_PL->data[gid] = i + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*(j - 1);
      }

      if((i == (NODES_X - 1)) && (j != 0) && (j != (NODES_Y - 1)))              // When on right border (excluding extremes):
      {
        index_PR->data[gid] = i + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*(j + 1);
        index_PL->data[gid] = (i - 1) + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*(j - 1);
      }

      if((j == 0) && (i != 0) && (i != (NODES_X - 1)))                          // When on bottom border (excluding extremes):
      {
        index_PR->data[gid] = (i + 1) + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*(j + 1);
        index_PL->data[gid] = (i - 1) + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*j;
      }

      if((j == (NODES_Y - 1)) && (i != 0) && (i != (NODES_X - 1)))              // When on high border (excluding extremes):
      {
        index_PR->data[gid] = (i + 1) + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*j;
        index_PL->data[gid] = (i - 1) + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*(j - 1);
      }

      if((i == 0) && (j == 0))                                                  // When on bottom left corner:
      {
        index_PR->data[gid] = (i + 1) + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*(j + 1);
        index_PL->data[gid] = i + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*j;
      }

      if((i == (NODES_X - 1)) && (j == 0))                                      // When on bottom right corner:
      {
        index_PR->data[gid] = i + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*(j + 1);
        index_PL->data[gid] = (i - 1) + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*j;
      }

      if((i == 0) && (j == (NODES_Y - 1)))                                      // When on top left corner:
      {
        index_PR->data[gid] = (i + 1) + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*j;
        index_PL->data[gid] = i + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*(j - 1);
      }

      if((i == (NODES_X - 1)) && (j == (NODES_Y - 1)))                          // When on top right corner:
      {
        index_PR->data[gid] = i + NODES_X*j;
        index_PU->data[gid] = i + NODES_X*j;
        index_PL->data[gid] = (i - 1) + NODES_X*j;
        index_PD->data[gid] = i + NODES_X*(j - 1);
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// WRITING DATA ON OPENCL QUEUE ////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  Q->write (voxel_point, 0);
  Q->write (voxel_color, 1);
  Q->write (position_int, 2);
  Q->write (velocity, 3);
  Q->write (velocity_int, 4);
  Q->write (acceleration, 5);
  Q->write (acceleration_int, 6);
  Q->write (gravity, 7);
  Q->write (stiffness, 8);
  Q->write (resting, 9);
  Q->write (friction, 10);
  Q->write (mass, 11);
  Q->write (index_PR, 12);
  Q->write (index_PU, 13);
  Q->write (index_PL, 14);
  Q->write (index_PD, 15);
  Q->write (freedom, 16);
  Q->write (dt, 17);

  ////////////////////////////////////////////////////////////////////////////////
  //////////////////////// SETTING OPENGL SHADER ARGUMENTS ///////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  S->setarg (voxel_point, 0);                                                   // Setting shader argument "0"...
  S->setarg (voxel_color, 1);                                                   // Setting shader argument "1"...
  S->build ();                                                                  // Building shader program...

  ////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// MAIN LOOP ////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  while(!gui->closed ())                                                        // Opening window...
  {
    bas->get_tic ();                                                            // Getting "tic" [us]...

    gui->clear ();                                                              // Clearing gui...
    gui->poll_events ();                                                        // Polling gui events...

    Q->acquire (voxel_point, 0);                                                // Acquiring OpenGL/CL shared argument...
    Q->acquire (voxel_color, 1);                                                // Acquiring OpenGL/CL shared argument...
    ctx->execute (K1, Q, NU_WAIT);                                              // Executing OpenCL kernel...
    ctx->execute (K2, Q, NU_WAIT);                                              // Executing OpenCL kernel...

    gui->plot (S);                                                              // Plotting shared arguments...
    Q->release (voxel_point, 0);                                                // Releasing OpenGL/CL shared argument...
    Q->release (voxel_color, 1);                                                // Releasing OpenGL/CL shared argument...

    gui->refresh ();                                                            // Refreshing gui...

    simulation_time += DT;
    time_step_number++;

    bas->get_toc ();                                                            // Getting "toc" [us]...

  }

  delete bas;
  delete gui;
  delete ctx;

  delete voxel_point;
  delete voxel_color;
  delete velocity;
  delete acceleration;

  delete position_int;
  delete velocity_int;
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

  delete freedom;
  delete dt;

  delete Q;
  delete K1;
  delete K2;

  return 0;
}
