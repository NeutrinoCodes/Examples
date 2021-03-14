/// @file

#define INTEROP       true                                                                          // "true" = use OpenGL-OpenCL interoperability.
#define SX            800                                                                           // Window x-size [px].
#define SY            600                                                                           // Window y-size [px].
#define NAME          "Neutrino - Mesh"                                                             // Window name.
#define ORB_X         0.0f                                                                          // x-axis orbit initial rotation.
#define ORB_Y         0.0f                                                                          // y-axis orbit initial rotation.
#define PAN_X         0.0f                                                                          // x-axis pan initial translation.
#define PAN_Y         0.0f                                                                          // y-axis pan initial translation.
#define PAN_Z         -2.0f                                                                         // z-axis pan initial translation.

#define TAG           1                                                                             // Surface tag.
#define DIM           2                                                                             // Surface dimension.
#define CELL_VERTICES 3                                                                             // Number of vertices per elementary cell.

#ifdef __linux__
  #define SHADER_HOME "../Mesh/Code/shader/"                                                        // Linux OpenGL shaders directory.
  #define KERNEL_HOME "../Mesh/Code/kernel/"                                                        // Linux OpenCL kernels directory.
  #define GMSH_HOME   "../Mesh/Code/mesh/"                                                          // Linux GMSH mesh directory.
#endif

#ifdef __APPLE__
  #define SHADER_HOME "../Mesh/Code/shader/"                                                        // Mac OpenGL shaders directory.
  #define KERNEL_HOME "../Mesh/Code/kernel/"                                                        // Mac OpenCL kernels directory.
  #define GMSH_HOME   "../Mesh/Code/mesh/"                                                          // Linux GMSH mesh directory.
#endif

#ifdef WIN32
  #define SHADER_HOME "..\\..\\Mesh\\Code\\shader\\"                                                // Windows OpenGL shaders directory.
  #define KERNEL_HOME "..\\..\\Mesh\\Code\\kernel\\"                                                // Windows OpenCL kernels directory.
  #define GMSH_HOME   "..\\..\\Mesh\\Code\\mesh\\"                                                  // Linux GMSH mesh directory.
#endif

#define SHADER_VERT   "voxel_vertex.vert"                                                           // OpenGL vertex shader.
#define SHADER_GEOM   "voxel_geometry.geom"                                                         // OpenGL geometry shader.
#define SHADER_FRAG   "voxel_fragment.frag"                                                         // OpenGL fragment shader.
#define KERNEL        "mesh_kernel.cl"                                                              // OpenCL kernel source.
#define GMSH_MESH     "Utah_teapot.msh"                                                             // GMSH mesh.

// INCLUDES:
#include "nu.hpp"                                                                                   // Neutrino's header file.

int main ()
{
  // INDEXES:
  size_t     i;                                                                                     // Index [#].
  size_t     j;                                                                                     // Index [#].
  size_t     j_min;                                                                                 // Index [#].
  size_t     j_max;                                                                                 // Index [#].

  // MOUSE PARAMETERS:
  float      ms_orbit_rate  = 1.0f;                                                                 // Orbit rotation rate [rev/s].
  float      ms_pan_rate    = 5.0f;                                                                 // Pan translation rate [m/s].
  float      ms_decaytime   = 1.25f;                                                                // Pan LP filter decay time [s].

  // GAMEPAD PARAMETERS:
  float      gmp_orbit_rate = 1.0f;                                                                 // Orbit angular rate coefficient [rev/s].
  float      gmp_pan_rate   = 1.0f;                                                                 // Pan translation rate [m/s].
  float      gmp_decaytime  = 1.25f;                                                                // Low pass filter decay time [s].
  float      gmp_deadzone   = 0.1f;                                                                 // Gamepad joystick deadzone [0...1].

  // NEUTRINO:
  opengl*    gl             = new opengl (NAME, SX, SY, ORB_X, ORB_Y, PAN_X, PAN_Y, PAN_Z);         // OpenGL context.
  opencl*    cl             = new opencl (NU_GPU);                                                  // OpenCL context.
  shader*    S              = new shader ();                                                        // OpenGL shader program.
  kernel*    K              = new kernel ();                                                        // OpenCL kernel array.

  // KERNEL VARIABLES:
  nu_float4* color          = new nu_float4 (0);                                                    // Color [].
  nu_float4* position       = new nu_float4 (1);                                                    // Position [m].
  nu_int*    central        = new nu_int (2);                                                       // Central nodes.
  nu_int*    neighbour      = new nu_int (3);                                                       // Neighbour.
  nu_int*    offset         = new nu_int (4);                                                       // Offset.

  // MESH:
  mesh*      obj            = new mesh (std::string (GMSH_HOME) + std::string (GMSH_MESH));         // Mesh obj.
  size_t     nodes;                                                                                 // Number of nodes.
  size_t     elements;                                                                              // Number of elements.
  size_t     groups;                                                                                // Number of groups.
  size_t     neighbours;                                                                            // Number of neighbours.
  float      x_min          = -1.0f;                                                                // "x_min" spatial boundary [m].
  float      x_max          = +1.0f;                                                                // "x_max" spatial boundary [m].
  float      y_min          = -1.0f;                                                                // "y_min" spatial boundary [m].
  float      y_max          = +1.0f;                                                                // "y_max" spatial boundary [m].

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////// DATA INITIALIZATION ///////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  // MESH:
  obj->process (TAG, DIM, NU_MSH_TRI_3);                                                            // Processing mesh...
  position->data  = obj->node_coordinates;                                                          // Setting all node coordinates...
  neighbour->data = obj->neighbour;                                                                 // Setting neighbour indices...
  offset->data    = obj->neighbour_offset;                                                          // Setting neighbour offsets...
  nodes           = obj->node.size ();                                                              // Getting the number of nodes...
  elements        = obj->element.size ();                                                           // Getting the number of elements...
  groups          = obj->group.size ();                                                             // Getting the number of groups...
  neighbours      = obj->neighbour.size ();                                                         // Getting the number of neighbours...
  std::cout << "nodes = " << nodes << std::endl;                                                    // Printing message...
  std::cout << "elements = " << elements/CELL_VERTICES << std::endl;                                // Printing message...
  std::cout << "groups = " << groups/CELL_VERTICES << std::endl;                                    // Printing message...
  std::cout << "neighbours = " << neighbours << std::endl;                                          // Printing message...

  // SETTING NEUTRINO ARRAYS ("surface" depending):
  for(i = 0; i < nodes; i++)
  {
    std::cout << "i = " << i << ", node index = " << obj->node[i] << ", neighbour indices:";        // Printing message...

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
      central->data.push_back (obj->node[i]);                                                       // Building central node tuple...

      std::cout << " " << neighbour->data[j];                                                       // Printing message...

      color->data.push_back ({1.0f, 0.0f, 0.0f, 1.0f});                                             // Setting link color...
    }

    std::cout << std::endl;                                                                         // Printing message...
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENCL KERNELS INITIALIZATION //////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  K->addsource (std::string (KERNEL_HOME) + std::string (KERNEL));                                  // Setting kernel source file...
  K->build (nodes, 0, 0);                                                                           // Building kernel program...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENGL SHADERS INITIALIZATION //////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_VERT), NU_VERTEX);                  // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_GEOM), NU_GEOMETRY);                // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_FRAG), NU_FRAGMENT);                // Setting shader source file...
  S->build (neighbours);                                                                            // Building shader program...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// SETTING OPENCL KERNEL ARGUMENTS //////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  cl->write ();                                                                                     // Writing OpenCL data...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////// APPLICATION LOOP /////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  while(!gl->closed ())                                                                             // Opening window...
  {
    cl->get_tic ();                                                                                 // Getting "tic" [us]...
    cl->acquire ();                                                                                 // Acquiring OpenCL kernel...
    cl->execute (K, NU_WAIT);                                                                       // Executing OpenCL kernel...
    cl->release ();                                                                                 // Releasing OpenCL kernel...

    gl->clear ();                                                                                   // Clearing gl...
    gl->poll_events ();                                                                             // Polling gl events...
    gl->mouse_navigation (ms_orbit_rate, ms_pan_rate, ms_decaytime);                                // Polling mouse...
    gl->gamepad_navigation (gmp_orbit_rate, gmp_pan_rate, gmp_decaytime, gmp_deadzone);             // Polling gamepad...
    gl->plot (S);                                                                                   // Plotting shared arguments...
    gl->refresh ();                                                                                 // Refreshing gl...

    if(gl->button_CROSS)
    {
      gl->close ();                                                                                 // Closing gl...
    }

    cl->get_toc ();                                                                                 // Getting "toc" [us]...
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////// CLEANUP /////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  delete cl;                                                                                        // Deleting OpenCL context...
  delete color;                                                                                     // Deleting color data...
  delete position;                                                                                  // Deleting position data...
  delete central;                                                                                   // Deleting centrals...
  delete neighbour;                                                                                 // Deleting neighbours...
  delete offset;                                                                                    // Deleting offset...
  delete K;                                                                                         // Deleting OpenCL kernel...

  return 0;
}
