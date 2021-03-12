/// @file     main.cpp
/// @author   Erik ZORZIN
/// @date     11MAR2021
/// @brief    Central gravitational potantial simulated attractor in a 3D continuum body.

#define INTEROP       true                                                                          // "true" = use OpenGL-OpenCL interoperability.
#define SX            800                                                                           // Window x-size [px].
#define SY            600                                                                           // Window y-size [px].
#define NAME          "Neutrino - Gravity"                                                          // Window name.
#define ORB_X         0.0f                                                                          // x-axis orbit initial rotation.
#define ORB_Y         0.0f                                                                          // y-axis orbit initial rotation.
#define PAN_X         0.0f                                                                          // x-axis pan initial translation.
#define PAN_Y         0.0f                                                                          // y-axis pan initial translation.
#define PAN_Z         -2.0f                                                                         // z-axis pan initial translation.

#ifdef __linux__
  #define SHADER_HOME "../Gravity/Code/shader/"                                                     // Linux OpenGL shaders directory.
  #define KERNEL_HOME "../Gravity/Code/kernel/"                                                     // Linux OpenCL kernels directory.
  #define GMSH_HOME   "../Gravity/Code/mesh/"                                                       // Linux GMSH mesh directory.
#endif

#ifdef __APPLE__
  #define SHADER_HOME "../Gravity/Code/shader/"                                                     // Mac OpenGL shaders directory.
  #define KERNEL_HOME "../Gravity/Code/kernel/"                                                     // Mac OpenCL kernels directory.
  #define GMSH_HOME   "../Gravity/Code/mesh/"                                                       // Linux GMSH mesh directory.
#endif

#ifdef WIN32
  #define SHADER_HOME "..\\..\\Gravity\\Code\\shader\\"                                             // Windows OpenGL shaders directory.
  #define KERNEL_HOME "..\\..\\Gravity\\Code\\kernel\\"                                             // Windows OpenCL kernels directory.
  #define GMSH_HOME   "..\\..\\Gravity\\Code\\mesh\\"                                               // Linux GMSH mesh directory.
#endif

#define SHADER_VERT   "voxel_vertex.vert"                                                           // OpenGL vertex shader.
#define SHADER_GEOM   "voxel_geometry.geom"                                                         // OpenGL geometry shader.
#define SHADER_FRAG   "voxel_fragment.frag"                                                         // OpenGL fragment shader.
#define KERNEL_1      "thekernel1.cl"                                                               // OpenCL kernel source.
#define KERNEL_2      "thekernel2.cl"                                                               // OpenCL kernel source.
#define UTILITIES     "utilities.cl"                                                                // OpenCL kernel source.
#define GMSH_MESH     "gravity.msh"                                                                 // GMSH mesh.

// INCLUDES:
#include "nu.hpp"                                                                                   // Neutrino header file.

int main ()
{
  // INDEXES:
  size_t             i;                                                                             // Index [#].
  size_t             j;                                                                             // Index [#].
  size_t             j_min;                                                                         // Index [#].
  size_t             j_max;                                                                         // Index [#].

  // MOUSE PARAMETERS:
  float              ms_orbit_rate  = 1.0f;                                                         // Orbit rotation rate [rev/s].
  float              ms_pan_rate    = 5.0f;                                                         // Pan translation rate [m/s].
  float              ms_decaytime   = 1.25f;                                                        // Pan LP filter decay time [s].

  // GAMEPAD PARAMETERS:
  float              gmp_orbit_rate = 1.0f;                                                         // Orbit angular rate coefficient [rev/s].
  float              gmp_pan_rate   = 1.0f;                                                         // Pan translation rate [m/s].
  float              gmp_decaytime  = 1.25f;                                                        // Low pass filter decay time [s].
  float              gmp_deadzone   = 0.1f;                                                         // Gamepad joystick deadzone [0...1].

  // NEUTRINO:
  opengl*            gl             = new opengl (NAME, SX, SY, ORB_X, ORB_Y, PAN_X, PAN_Y, PAN_Z); // OpenGL context.
  opencl*            cl             = new opencl (NU_GPU);                                          // OpenCL context.
  shader*            S              = new shader ();                                                // OpenGL shader program.
  kernel*            K1             = new kernel ();                                                // OpenCL kernel array.
  kernel*            K2             = new kernel ();                                                // OpenCL kernel array.

  // KERNEL VARIABLES:
  nu_float4*         color          = new nu_float4 (0);                                            // Color [].
  nu_float4*         position       = new nu_float4 (1);                                            // Position [m].
  nu_float4*         velocity       = new nu_float4 (2);                                            // Velocity [m/s].
  nu_float4*         acceleration   = new nu_float4 (3);                                            // Acceleration [m/s^2].
  nu_float4*         position_int   = new nu_float4 (4);                                            // Position (intermediate) [m].
  nu_float4*         velocity_int   = new nu_float4 (5);                                            // Velocity (intermediate) [m/s].
  nu_float*          radius         = new nu_float (6);                                             // Nucleus radius [m].
  nu_float*          stiffness      = new nu_float (7);                                             // Stiffness.
  nu_float*          resting        = new nu_float (8);                                             // Resting.
  nu_float*          friction       = new nu_float (9);                                             // Friction.
  nu_float*          mass           = new nu_float (10);                                            // Mass.
  nu_int*            central        = new nu_int (11);                                              // Central nodes.
  nu_int*            neighbour      = new nu_int (12);                                              // Neighbour.
  nu_int*            offset         = new nu_int (13);                                              // Offset.
  nu_int*            freedom        = new nu_int (14);                                              // Freedom.
  nu_float*          dt             = new nu_float (15);                                            // Time step [s].

  // MESH:
  mesh*              gravity        = new mesh (std::string (GMSH_HOME) + std::string (GMSH_MESH)); // Mesh cloth.
  size_t             nodes;                                                                         // Number of nodes.
  size_t             elements;                                                                      // Number of elements.
  size_t             groups;                                                                        // Number of groups.
  size_t             neighbours;                                                                    // Number of neighbours.
  std::vector<GLint> point;                                                                         // Point on frame.
  size_t             point_nodes;                                                                   // Number of point nodes.
  float              x_min          = -1.0f;                                                        // "x_min" spatial boundary [m].
  float              x_max          = +1.0f;                                                        // "x_max" spatial boundary [m].
  float              y_min          = -1.0f;                                                        // "y_min" spatial boundary [m].
  float              y_max          = +1.0f;                                                        // "y_max" spatial boundary [m].
  float              z_min          = -1.0f;                                                        // "z_min" spatial boundary [m].
  float              z_max          = +1.0f;                                                        // "z_max" spatial boundary [m].
  float              ds             = 1.0f;                                                         // Cell size [m].

  // SIMULATION VARIABLES:
  float              m              = 0.001f;                                                       // Node mass [kg].
  float              K              = 300.0f;                                                       // Link elastic constant [kg/s^2].
  float              B              = 1.0f;                                                         // Damping [kg*s*m].
  float              R0             = 0.2f;                                                         // Nucleus radius [m].
  float              dt_critical;                                                                   // Critical time step [s].
  float              dt_simulation;                                                                 // Simulation time step [s].

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////// DATA INITIALIZATION ///////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  // MESH:
  gravity->process (1, 3, NU_MSH_HEX_8);                                                            // Processing mesh...

  position->data  = gravity->node_coordinates;                                                      // Setting all node coordinates...
  neighbour->data = gravity->neighbour;                                                             // Setting neighbour indices...
  offset->data    = gravity->neighbour_offset;                                                      // Setting neighbour offsets...
  resting->data   = gravity->neighbour_length;                                                      // Setting resting distances...

  nodes           = gravity->node.size ();                                                          // Getting the number of nodes...
  elements        = gravity->element.size ();                                                       // Getting the number of elements...
  groups          = gravity->group.size ();                                                         // Getting the number of groups...
  neighbours      = gravity->neighbour.size ();                                                     // Getting the number of neighbours...

  std::cout << "nodes = " << nodes << std::endl;
  std::cout << "elements = " << elements << std::endl;
  std::cout << "groups = " << groups << std::endl;
  std::cout << "neighbours = " << neighbours << std::endl;
  std::cout << "offsets = " << gravity->neighbour_offset.size () << std::endl;
  std::cout << "lenghts = " << gravity->neighbour_length.size () << std::endl;
  std::cout << "links = " << gravity->neighbour_link.size () << std::endl;

  dt_critical     = sqrt (m/K);                                                                     // Critical time step [s].
  dt_simulation   = 0.5f*dt_critical;                                                               // Simulation time step [s].

  // SETTING NEUTRINO ARRAYS (parameters):
  friction->data.push_back (B);                                                                     // Setting friction...
  dt->data.push_back (dt_simulation);                                                               // Setting time step...
  radius->data.push_back (R0);                                                                      // Setting nucleus radius...

  // SETTING NEUTRINO ARRAYS ("nodes" depending):
  for(i = 0; i < nodes; i++)
  {
    position_int->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                        // Setting intermediate position...
    velocity->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                            // Setting velocity...
    velocity_int->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                        // Setting intermediate velocity...
    acceleration->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                        // Setting acceleration...
    mass->data.push_back (m);                                                                       // Setting mass...
    freedom->data.push_back (1);                                                                    // Setting freedom flag...

    // Computing minimum element offset index:
    if(i == 0)
    {
      j_min = 0;                                                                                    // Setting minimum element offset index...
    }
    else
    {
      j_min = offset->data[i - 1];                                                                  // Setting minimum element offset index...
    }

    j_max = offset->data[i];                                                                        // Setting maximum element offset index...

    for(j = j_min; j < j_max; j++)
    {
      central->data.push_back (gravity->node[i]);                                                   // Building central node vector...
      stiffness->data.push_back (K);                                                                // Setting link stiffness...

      if(resting->data[j] > 0.21)
      {
        color->data.push_back ({0.0f, 0.0f, 0.0f, 0.0f});                                           // Setting color...
      }
      else
      {
        color->data.push_back ({0.0f, 1.0f, 0.0f, 1.0f});                                           // Setting color...
      }
    }
  }

  for(j = 1; j < 9; j++)
  {
    gravity->process (j, 0, NU_MSH_PNT);                                                            // Processing mesh...
    point       = gravity->node;                                                                    // Getting nodes on border...
    point_nodes = point.size ();                                                                    // Getting the number of nodes on border...

    // SETTING NEUTRINO ARRAYS ("border" depending):
    for(i = 0; i < point_nodes; i++)
    {
      freedom->data[point[i]] = 0;                                                                  // Resetting freedom flag...
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENCL KERNELS INITIALIZATION /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  K1->addsource (std::string (KERNEL_HOME) + std::string (UTILITIES));                              // Setting kernel source file...
  K1->addsource (std::string (KERNEL_HOME) + std::string (KERNEL_1));                               // Setting kernel source file...
  K1->build (nodes, 0, 0);                                                                          // Building kernel program...

  K2->addsource (std::string (KERNEL_HOME) + std::string (UTILITIES));                              // Setting kernel source file...
  K2->addsource (std::string (KERNEL_HOME) + std::string (KERNEL_2));                               // Setting kernel source file...
  K2->build (nodes, 0, 0);                                                                          // Building kernel program...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENGL SHADERS INITIALIZATION /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_VERT), NU_VERTEX);                  // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_GEOM), NU_GEOMETRY);                // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_FRAG), NU_FRAGMENT);                // Setting shader source file...
  S->build (neighbours);                                                                            // Building shader program...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// SETTING OPENCL KERNEL ARGUMENTS /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  cl->write ();

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////// APPLICATION LOOP ////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  while(!gl->closed ())                                                                             // Opening window...
  {
    cl->get_tic ();                                                                                 // Getting "tic" [us]...
    cl->acquire ();
    cl->execute (K1, NU_WAIT);                                                                      // Executing OpenCL kernel...
    cl->execute (K2, NU_WAIT);                                                                      // Executing OpenCL kernel...
    cl->release ();

    gl->clear ();                                                                                   // Clearing gl...
    gl->poll_events ();                                                                             // Polling gl events...
    gl->mouse_navigation (ms_orbit_rate, ms_pan_rate, ms_decaytime);
    gl->gamepad_navigation (gmp_orbit_rate, gmp_pan_rate, gmp_decaytime, gmp_deadzone);
    gl->plot (S);                                                                                   // Plotting shared arguments...

    gl->refresh ();                                                                                 // Refreshing gl...

    if(gl->button_CROSS)
    {
      gl->close ();                                                                                 // Closing gl...
    }

    cl->get_toc ();                                                                                 // Getting "toc" [us]...
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////// CLEANUP ////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  delete cl;                                                                                        // Deleting OpenCL context...
  delete color;                                                                                     // Deleting color data...
  delete position;                                                                                  // Deleting position data...
  delete position_int;                                                                              // Deleting intermediate position data...
  delete velocity;                                                                                  // Deleting velocity data...
  delete velocity_int;                                                                              // Deleting intermediate velocity data...
  delete acceleration;                                                                              // Deleting acceleration data...
  delete stiffness;                                                                                 // Deleting stiffness data...
  delete resting;                                                                                   // Deleting resting data...
  delete friction;                                                                                  // Deleting friction data...
  delete neighbour;                                                                                 // Deleting neighbours...
  delete offset;                                                                                    // Deleting offset...
  delete freedom;                                                                                   // Deleting freedom flag data...
  delete dt;                                                                                        // Deleting time step data...
  delete K1;                                                                                        // Deleting OpenCL kernel...
  delete K2;                                                                                        // Deleting OpenCL kernel...

  return 0;
}