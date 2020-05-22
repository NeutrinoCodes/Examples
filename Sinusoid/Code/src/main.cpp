/// @file     main.cpp
/// @author   Erik ZORZIN
/// @date     24OCT2019
/// @brief    It implements an example of a Neutrino application.

// OPENGL:
#define GUI_SIZE_X    800                                                                           // Window x-size [px].
#define GUI_SIZE_Y    600                                                                           // Window y-size [px].
#define GUI_NAME      "Neutrino - Sinusoid"                                                         // Window name.

// OPENCL:
#define QUEUE_NUM     1                                                                             // Number of OpenCL queues [#].
#define KERNEL_NUM    1                                                                             // Number of OpenCL kernel [#].
#define KERNEL_FILE   "sine_kernel.cl"                                                              // OpenCL kernel.

#ifdef __linux__
  #define SHADER_HOME "../Sinusoid/Code/shader"                                                     // Linux OpenGL shaders directory.
  #define KERNEL_HOME "../Sinusoid/Code/kernel"                                                     // Linux OpenCL kernels directory.
#endif

#ifdef __APPLE__
  #define SHADER_HOME "../Sinusoid/Code/shader"                                                     // Mac OpenGL shaders directory.
  #define KERNEL_HOME "../Sinusoid/Code/kernel"                                                     // Mac OpenCL kernels directory.
#endif

#ifdef WIN32
  #define SHADER_HOME "..\\Sinusoid\\Code\\shader"                                                  // Windows OpenGL shaders directory.
  #define KERNEL_HOME "..\\Sinusoid\\Code\\kernel"                                                  // Windows OpenCL kernels directory.
#endif

#define SHADER_VERT   "voxel.vert"                                                                  // OpenGL vertex shader.
#define SHADER_GEOM   "voxel.geom"                                                                  // OpenGL geometry shader.
#define SHADER_FRAG   "voxel.frag"                                                                  // OpenGL fragment shader.

// INCLUDES:
#include "nu.hpp"                                                                                   // Neutrino header file.

int main ()
{
  // DATA:
  float     x_min              = -1.0f;                                                             // "x_min" spatial boundary [m].
  float     x_max              = +1.0f;                                                             // "x_max" spatial boundary [m].
  float     y_min              = -1.0f;                                                             // "y_min" spatial boundary [m].
  float     y_max              = +1.0f;                                                             // "y_max" spatial boundary [m].
  size_t    nodes_x            = 100;                                                               // Number of nodes in "X" direction [#].
  size_t    nodes_y            = 100;                                                               // Number of nodes in "Y" direction [#].
  size_t    nodes              = nodes_x*nodes_y;                                                   // Total number of nodes [#].
  float     dx                 = (x_max - x_min)/(nodes_x - 1);                                     // x-axis mesh spatial size [m].
  float     dy                 = (y_max - y_min)/(nodes_y - 1);                                     // y-axis mesh spatial size [m].
  size_t    i                  = 0;                                                                 // "x" direction index.
  size_t    j                  = 0;                                                                 // "y" direction index.
  size_t    gid                = 0;                                                                 // Global index [#].
  float4G*  position           = new float4G ();                                                    // OpenGL float4G.
  float4G*  color              = new float4G ();                                                    // OpenGL float4G.
  float1*   t                  = new float1 ();                                                     // Time [s].

  // GUI PARAMETERS (orbit):
  float     orbit_x_init       = 0.0f;                                                              // x-axis orbit initial rotation.
  float     orbit_y_init       = 0.0f;                                                              // y-axis orbit initial rotation.

  // GUI PARAMETERS (pan):
  float     pan_x_init         = 0.0f;                                                              // x-axis pan initial translation.
  float     pan_y_init         = 0.0f;                                                              // y-axis pan initial translation.
  float     pan_z_init         = -2.0f;                                                             // z-axis pan initial translation.

  // GUI PARAMETERS (mouse):
  float     mouse_orbit_rate   = 1.0;                                                               // Orbit rotation rate [rev/s].
  float     mouse_pan_rate     = 5.0;                                                               // Pan translation rate [m/s].
  float     mouse_decaytime    = 1.25;                                                              // Pan LP filter decay time [s].

  // GUI PARAMETERS (gamepad):
  float     gamepad_orbit_rate = 1.0;                                                               // Orbit angular rate coefficient [rev/s].
  float     gamepad_pan_rate   = 1.0;                                                               // Pan translation rate [m/s].
  float     gamepad_decaytime  = 1.25;                                                              // Low pass filter decay time [s].
  float     gamepad_deadzone   = 0.1;                                                               // Gamepad joystick deadzone [0...1].

  // NEUTRINO:
  neutrino* bas                = new neutrino ();                                                   // Neutrino baseline.
  opengl*   gui                = new opengl ();                                                     // OpenGL context.
  opencl*   ctx                = new opencl ();                                                     // OpenCL context.
  shader*   S                  = new shader ();                                                     // OpenGL shader program.
  queue*    Q                  = new queue ();                                                      // OpenCL queue.
  kernel*   K                  = new kernel ();                                                     // OpenCL kernel array.
  size_t    kernel_sx          = nodes;                                                             // Kernel dimension "x" [#].
  size_t    kernel_sy          = 0;                                                                 // Kernel dimension "y" [#].
  size_t    kernel_sz          = 0;                                                                 // Kernel dimension "z" [#].

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////// DATA INITIALIZATION //////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  position->init (nodes);                                                                           // Initializing OpenGL point array...
  color->init (nodes);                                                                              // Initializing OpenGL color array...
  t->init (nodes);                                                                                  // Initializing time...

  position->name = "voxel_center";                                                                  // Setting variable name in OpenGL shader...
  color->name    = "voxel_color";                                                                   // Setting variable name in OpenGL shader...

  for(j = 0; j < nodes_y; j++)
  {
    for(i = 0; i < nodes_x; i++)
    {
      // Computing global index:
      gid                   = i + nodes_x*j;                                                        // Computing global index...

      // Setting point coordinates:
      position->data[gid].x = x_min + i*dx;                                                         // Setting "x" position...
      position->data[gid].y = y_min + j*dy;                                                         // Setting "y" position...
      position->data[gid].z = 0.0f;                                                                 // Setting "z" position...
      position->data[gid].w = 1.0f;                                                                 // Setting "w" position...

      // Setting point colors:
      color->data[gid].x    = 0.01f*(rand () % 100);                                                // Setting "r" color coordinate...
      color->data[gid].y    = 0.01f*(rand () % 100);                                                // Setting "g" color coordinate...
      color->data[gid].z    = 0.01f*(rand () % 100);                                                // Setting "b" color coordinate...
      color->data[gid].w    = 1.0f;                                                                 // Setting "a" color coordinate...

      // Setting time:
      t->data[gid]          = 0.0f;                                                                 // Setting time...
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////// NEUTRINO INITIALIZATION /////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  bas->init (QUEUE_NUM, KERNEL_NUM);                                                                // Initializing Neutrino baseline...

  // Initializing OpenGL context...
  gui->init                                                                                         // Initializing GUI...
  (
   bas,                                                                                             // Neutrino baseline.
   GUI_SIZE_X,                                                                                      // GUI x-size [px].
   GUI_SIZE_Y,                                                                                      // GUI y-size [px.]
   GUI_NAME,                                                                                        // GUI name.
   orbit_x_init,                                                                                    // Initial x-orbit.
   orbit_y_init,                                                                                    // Initial y-orbit.
   pan_x_init,                                                                                      // Initial x-pan.
   pan_y_init,                                                                                      // Initial y-pan.
   pan_z_init                                                                                       // Initial z-pan.
  );

  // Initializing OpenCL context...
  ctx->init (
             bas,                                                                                   // Neutrino baseline.
             gui,                                                                                   // GUI.
             NU_GPU                                                                                 // GPU client.
            );

  // Initializing OpenGL shader...
  S->init (
           bas,                                                                                     // Neutrino baseline.
           SHADER_HOME,                                                                             // Shader home directory.
           SHADER_VERT,                                                                             // Vertex shader file name.
           SHADER_GEOM,                                                                             // Geometry shader file name.
           SHADER_FRAG                                                                              // Fragment shader file name.
          );

  // Initializing OpenCL queue...
  Q->init (
           bas                                                                                      // Neutrino baseline.
          );

  // Initializing OpenCL kernel...
  K->init (
           bas,                                                                                     // Neutrino baseline.
           KERNEL_HOME,                                                                             // Kernel home directory.
           KERNEL_FILE,                                                                             // Kernel file name.
           kernel_sx,                                                                               // Kernel dimension "x" [#].
           kernel_sy,                                                                               // Kernel dimension "y" [#].
           kernel_sz                                                                                // Kernel dimension "z" [#].
          );

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// SETTING OPENCL KERNEL ARGUMENTS /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  K->setarg (position, 0);                                                                          // Setting kernel argument "0"...
  K->setarg (color, 1);                                                                             // Setting kernel argument "1"...
  K->setarg (t, 2);                                                                                 // Setting kernel argument "2"...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// WRITING DATA ON OPENCL QUEUE //////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  Q->write (position, 0);                                                                           // Uploading argument "0" on kernel...
  Q->write (color, 1);                                                                              // Uploading argument "1" on kernel...
  Q->write (t, 2);                                                                                  // Uploading argument "2" on kernel...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////// SETTING OPENGL SHADER ARGUMENTS ////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  S->setarg (position, 0);                                                                          // Setting shader argument "0"...
  S->setarg (color, 1);                                                                             // Setting shader argument "1"...
  S->build ();                                                                                      // Building shader program...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////// APPLICATION LOOP ////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  while(!gui->closed ())                                                                            // Opening gui...
  {
    bas->get_tic ();                                                                                // Getting "tic" [us]...
    gui->clear ();                                                                                  // Clearing gui...
    gui->poll_events ();                                                                            // Polling gui events...

    Q->write (t, 2);                                                                                // Writing time to OpenCL queue...

    Q->acquire (position, 0);                                                                       // Acquiring OpenGL/CL shared argument...
    Q->acquire (color, 1);                                                                          // Acquiring OpenGL/CL shared argument...
    ctx->execute (K, Q, NU_WAIT);                                                                   // Executing OpenCL kenrnel...
    Q->release (position, 0);                                                                       // Releasing OpenGL/CL shared argument...
    Q->release (color, 1);                                                                          // Releasing OpenGL/CL shared argument...

    gui->mouse_navigation (
                           mouse_orbit_rate,                                                        // Orbit angular rate coefficient [rev/s].
                           mouse_pan_rate,                                                          // Pan translation rate [m/s].
                           mouse_decaytime                                                          // Orbit low pass decay time [s].
                          );

    gui->gamepad_navigation (
                             gamepad_orbit_rate,                                                    // Orbit angular rate coefficient [rev/s].
                             gamepad_pan_rate,                                                      // Pan translation rate [m/s].
                             gamepad_decaytime,                                                     // Low pass filter decay time [s].
                             gamepad_deadzone                                                       // Gamepad joystick deadzone [0...1].
                            );

    if(gui->button_CROSS)                                                                           // Checking CROSS button...
    {
      gui->close ();                                                                                // Closing gui...
    }

    gui->plot (S);                                                                                  // Plotting shared arguments...

    Q->read (t, 2);                                                                                 // Reading time from OpenCL queue...

    gui->refresh ();                                                                                // Refreshing gui...
    bas->get_toc ();                                                                                // Getting "toc" [us]...
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////// CLEANUP ////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  delete bas;                                                                                       // Deleting Neutrino baseline...
  delete gui;                                                                                       // Deleting OpenGL gui ...
  delete ctx;                                                                                       // Deleting OpenCL context...
  delete S;                                                                                         // Deleting OpenGL shader...
  delete position;                                                                                  // Deleting OpenGL point...
  delete color;                                                                                     // Deleting OpenGL color...
  delete Q;                                                                                         // Deleting OpenCL queue...
  delete K;                                                                                         // Deleting OpenCL kernel...

  return 0;
}
