/// @file     main.cpp
/// @author   Erik ZORZIN
/// @date     24OCT2019
/// @brief    It implements an example of a Neutrino application.

#define INTEROP       true                                                                          // "true" = use OpenGL-OpenCL interoperability.
#define SX            800                                                                           // Window x-size [px].
#define SY            600                                                                           // Window y-size [px].
#define NM            "Neutrino - Sinusoid"                                                         // Window name.
#define OX            0.0f                                                                          // x-axis orbit initial rotation.
#define OY            0.0f                                                                          // y-axis orbit initial rotation.
#define PX            0.0f                                                                          // x-axis pan initial translation.
#define PY            0.0f                                                                          // y-axis pan initial translation.
#define PZ            -2.0f                                                                         // z-axis pan initial translation.

#ifdef __linux__
  #define SHADER_HOME "../../Sinusoid/Code/shader/"                                                 // Linux OpenGL shaders directory.
  #define KERNEL_HOME "../../Sinusoid/Code/kernel/"                                                 // Linux OpenCL kernels directory.
#endif

#ifdef WIN32
  #define SHADER_HOME "..\\..\\Sinusoid\\Code\\shader\\"                                            // Windows OpenGL shaders directory.
  #define KERNEL_HOME "..\\..\\Sinusoid\\Code\\kernel\\"                                            // Windows OpenCL kernels directory.
#endif

#define KERNEL_FILE   "sine_kernel.cl"                                                              // OpenCL kernel.
#define SHADER_VERT   "voxel.vert"                                                                  // OpenGL vertex shader.
#define SHADER_GEOM   "voxel.geom"                                                                  // OpenGL geometry shader.
#define SHADER_FRAG   "voxel.frag"                                                                  // OpenGL fragment shader.

// INCLUDES:
#include "nu.hpp"                                                                                   // Neutrino header file.

int main ()
{
  // INDICES:
  size_t              i              = 0;                                                           // "x" direction index.
  size_t              j              = 0;                                                           // "y" direction index.

  // MOUSE PARAMETERS:
  float               ms_orbit_rate  = 1.0f;                                                        // Orbit rotation rate [rev/s].
  float               ms_pan_rate    = 5.0f;                                                        // Pan translation rate [m/s].
  float               ms_decaytime   = 1.25f;                                                       // Pan LP filter decay time [s].

  // GAMEPAD PARAMETERS:
  float               gmp_orbit_rate = 1.0f;                                                        // Orbit angular rate coefficient [rev/s].
  float               gmp_pan_rate   = 1.0f;                                                        // Pan translation rate [m/s].
  float               gmp_decaytime  = 1.25f;                                                       // Low pass filter decay time [s].
  float               gmp_deadzone   = 0.30f;                                                       // Gamepad joystick deadzone [0...1].

  // OPENGL:
  nu::opengl*         gl             = new nu::opengl (NM, SX, SY, OX, OY, PX, PY, PZ);             // OpenGL context.
  nu::shader*         S              = new nu::shader ();                                           // OpenGL shader program.
  nu::projection_mode proj_mode      = nu::MONOCULAR;                                               // OpenGL projection mode.

  // OPENCL:
  nu::opencl*         cl             = new nu::opencl (nu::GPU);                                    // OpenCL context.
  nu::kernel*         K              = new nu::kernel ();                                           // OpenCL kernel array.
  nu::float4*         color          = new nu::float4 (0);                                          // Color [].
  nu::float4*         position       = new nu::float4 (1);                                          // Position [m].
  nu::float1*         t              = new nu::float1 (2);                                          // Time step [s].

  // SIMULATION:
  float               x_min          = -1.0f;                                                       // "x_min" spatial boundary [m].
  float               x_max          = +1.0f;                                                       // "x_max" spatial boundary [m].
  float               y_min          = -1.0f;                                                       // "y_min" spatial boundary [m].
  float               y_max          = +1.0f;                                                       // "y_max" spatial boundary [m].
  size_t              nodes_x        = 100;                                                         // Number of nodes in "X" direction [#].
  size_t              nodes_y        = 100;                                                         // Number of nodes in "Y" direction [#].
  size_t              nodes          = nodes_x*nodes_y;                                             // Total number of nodes [#].
  float               dx             = (x_max - x_min)/(nodes_x - 1);                               // x-axis mesh spatial size [m].
  float               dy             = (y_max - y_min)/(nodes_y - 1);                               // y-axis mesh spatial size [m].

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////// DATA INITIALIZATION //////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  for(j = 0; j < nodes_y; j++)
  {
    for(i = 0; i < nodes_x; i++)
    {
      // Setting point coordinates:
      position->data.push_back (
      {
        x_min + i*dx,
        y_min + j*dy,
        0.0f,
        1.0f}
                               );                                                                   // Setting position...

      // Setting point colors:
      color->data.push_back (
      {
        0.01f*(rand () % 100),
        0.01f*(rand () % 100),
        0.01f*(rand () % 100),
        1.0f
      }
                            );                                                                      // Setting "r" color coordinate...

      // Setting time:
      t->data.push_back (0.0f);                                                                     // Setting time...
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENCL KERNELS INITIALIZATION //////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  K->addsource (std::string (KERNEL_HOME) + std::string (KERNEL_FILE));                             // Setting kernel source file...
  K->build (nodes, 0, 0);                                                                           // Building kernel program...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENGL SHADERS INITIALIZATION //////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_VERT), nu::VERTEX);                 // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_GEOM), nu::GEOMETRY);               // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_FRAG), nu::FRAGMENT);               // Setting shader source file...
  S->build (nodes);                                                                                 // Building shader program...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// SETTING OPENCL KERNEL ARGUMENTS //////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  cl->write ();                                                                                     // Writing OpenCL data...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////// APPLICATION LOOP ////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  while(!gl->closed ())                                                                             // Opening gui...
  {
    cl->get_tic ();                                                                                 // Getting "tic" [us]...
    cl->acquire ();                                                                                 // Acquiring OpenCL kernel...
    cl->execute (K, nu::WAIT);                                                                      // Executing OpenCL kernel...
    cl->release ();                                                                                 // Releasing OpenCL kernel...

    gl->begin ();                                                                                   // Beginning gl...
    gl->poll_events ();                                                                             // Polling gl events...
    gl->mouse_navigation (ms_orbit_rate, ms_pan_rate, ms_decaytime);                                // Polling mouse...
    gl->gamepad_navigation (gmp_orbit_rate, gmp_pan_rate, gmp_decaytime, gmp_deadzone);             // Polling gamepad...
    gl->plot (S, proj_mode);                                                                        // Plotting shared arguments...

    if(gl->key_M)
    {
      proj_mode = nu::MONOCULAR;                                                                    // Setting monocular projection...
    }

    if(gl->key_B)
    {
      proj_mode = nu::BINOCULAR;                                                                    // Setting binocular projection...
    }

    if(gl->button_CROSS || gl->key_E)
    {
      gl->close ();                                                                                 // Closing gl...
    }

    gl->end ();                                                                                     // Ending gl...
    cl->get_toc ();                                                                                 // Getting "toc" [us]...
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////// CLEANUP ////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  delete gl;                                                                                        // Deleting OpenGL gui ...
  delete cl;                                                                                        // Deleting OpenCL context...
  delete S;                                                                                         // Deleting OpenGL shader...
  delete K;                                                                                         // Deleting OpenCL kernel...
  delete position;                                                                                  // Deleting OpenGL point...
  delete color;                                                                                     // Deleting OpenGL color...
  delete t;                                                                                         // Deleting time...

  return 0;
}
