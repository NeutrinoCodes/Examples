/// @file

// OPENGL:
#define INTEROP       true                                                                          // "true" = use OpenGL-OpenCL interoperability.
#define GUI_SX        800                                                                           // Window x-size [px].
#define GUI_SY        600                                                                           // Window y-size [px].
#define GUI_NAME      "Neutrino - Cloth_gmsh"                                                       // Window name.

#ifdef __linux__
  #define SHADER_HOME "../Cloth_gmsh/Code/shader/"                                                  // Linux OpenGL shaders directory.
  #define KERNEL_HOME "../Cloth_gmsh/Code/kernel/"                                                  // Linux OpenCL kernels directory.
  #define GMSH_HOME   "../Cloth_gmsh/Code/mesh/"                                                    // Linux GMSH mesh directory.
#endif

#ifdef __APPLE__
  #define SHADER_HOME "../Cloth_gmsh/Code/shader/"                                                  // Mac OpenGL shaders directory.
  #define KERNEL_HOME "../Cloth_gmsh/Code/kernel/"                                                  // Mac OpenCL kernels directory.
  #define GMSH_HOME   "../Cloth_gmsh/Code/mesh/"                                                    // Linux GMSH mesh directory.
#endif

#ifdef WIN32
  #define SHADER_HOME "..\\..\\Cloth_gmsh\\Code\\shader\\"                                          // Windows OpenGL shaders directory.
  #define KERNEL_HOME "..\\..\\Cloth_gmsh\\Code\\kernel\\"                                          // Windows OpenCL kernels directory.
  #define GMSH_HOME   "..\\..\\Cloth_gmsh\\Code\\mesh\\"                                            // Linux GMSH mesh directory.
#endif

#define SHADER_VERT   "voxel_vertex.vert"                                                           // OpenGL vertex shader.
#define SHADER_GEOM_1 "voxel_geometry_1.geom"                                                       // OpenGL geometry shader.
#define SHADER_GEOM_2 "voxel_geometry_2.geom"                                                       // OpenGL geometry shader.
#define SHADER_FRAG   "voxel_fragment.frag"                                                         // OpenGL fragment shader.
#define KERNEL_1      "thekernel_1.cl"                                                              // OpenCL kernel source.
#define KERNEL_2      "thekernel_2.cl"                                                              // OpenCL kernel source.
#define GMSH_MESH     "Square_triangles.msh"                                                        // GMSH mesh.

// OPENCL:
#define QUEUE_NUM     1                                                                             // # of OpenCL queues [#].
#define KERNEL_NUM    2                                                                             // # of OpenCL kernel [#].

// INCLUDES:
#include "nu.hpp"                                                                                   // Neutrino's header file.

int main ()
{
  // INDEXES:
  size_t                i;                                                                          // Index [#].
  size_t                j;                                                                          // Index [#].
  size_t                j_min;                                                                      // Index [#].
  size_t                j_max;                                                                      // Index [#].
  size_t                k;                                                                          // Index [#].

  // gl PARAMETERS (orbit):
  float                 orbit_x0           = 0.0f;                                                  // x-axis orbit initial rotation.
  float                 orbit_y0           = 0.0f;                                                  // y-axis orbit initial rotation.

  // gl PARAMETERS (pan):
  float                 pan_x0             = 0.0f;                                                  // x-axis pan initial translation.
  float                 pan_y0             = 0.0f;                                                  // y-axis pan initial translation.
  float                 pan_z0             = -2.0f;                                                 // z-axis pan initial translation.

  // gl PARAMETERS (mouse):
  float                 mouse_orbit_rate   = 1.0f;                                                  // Orbit rotation rate [rev/s].
  float                 mouse_pan_rate     = 5.0f;                                                  // Pan translation rate [m/s].
  float                 mouse_decaytime    = 1.25f;                                                 // Pan LP filter decay time [s].

  // gl PARAMETERS (gamepad):
  float                 gamepad_orbit_rate = 1.0f;                                                  // Orbit angular rate coefficient [rev/s].
  float                 gamepad_pan_rate   = 1.0f;                                                  // Pan translation rate [m/s].
  float                 gamepad_decaytime  = 1.25f;                                                 // Low pass filter decay time [s].
  float                 gamepad_deadzone   = 0.1f;                                                  // Gamepad joystick deadzone [0...1].

  // NEUTRINO:
  neutrino*             nu                 = new neutrino ();                                       // Neutrino baseline.
  opengl*               gl                 = new opengl ();                                         // OpenGL context.
  opencl*               cl                 = new opencl ();                                         // OpenCL context.
  shader*               S                  = new shader ();                                         // OpenGL shader program.
  queue*                Q                  = new queue ();                                          // OpenCL queue.
  kernel*               K1                 = new kernel ();                                         // OpenCL kernel array.
  kernel*               K2                 = new kernel ();                                         // OpenCL kernel array.
  size_t                kernel_sx;                                                                  // Kernel dimension "x" [#].
  size_t                kernel_sy;                                                                  // Kernel dimension "y" [#].
  size_t                kernel_sz;                                                                  // Kernel dimension "z" [#].
  std::vector<nu_data*> data;                                                                       // Neutrino data vector.

  // KERNEL VARIABLES:
  nu_float4*            color              = new nu_float4 (data, 0);                               // Color [].
  nu_float4*            position           = new nu_float4 (data, 1);                               // Position [m].
  nu_float4*            velocity           = new nu_float4 (data, 2);                               // Velocity [m/s].
  nu_float4*            acceleration       = new nu_float4 (data, 3);                               // Acceleration [m/s^2].
  nu_float4*            position_int       = new nu_float4 (data, 4);                               // Position (intermediate) [m].
  nu_float4*            velocity_int       = new nu_float4 (data, 5);                               // Velocity (intermediate) [m/s].
  nu_float4*            gravity            = new nu_float4 (data, 6);                               // Gravity [m/s^2].
  nu_float*             stiffness          = new nu_float (data, 7);                                // Stiffness.
  nu_float*             resting            = new nu_float (data, 8);                                // Resting.
  nu_float*             friction           = new nu_float (data, 9);                                // Friction.
  nu_float*             mass               = new nu_float (data, 10);                               // Mass [kg].
  nu_int*               neighbour          = new nu_int (data, 11);                                 // Neighbour.
  nu_int*               offset             = new nu_int (data, 12);                                 // Offset.
  nu_int*               freedom            = new nu_int (data, 13);                                 // Freedom.
  nu_float*             dt                 = new nu_float (data, 14);                               // Time step [s].

  // MESH:
  mesh*                 cloth              = new mesh ();                                           // Mesh cloth.
  size_t                nodes;                                                                      // Number of nodes.
  size_t                elements;                                                                   // Number of elements.
  size_t                neighbours;                                                                 // Number of neighbours.
  size_t                border_nodes;                                                               // Number of border nodes.
  std::vector<size_t>   neighbourhood;                                                              // Neighbourhood.
  std::vector<size_t>   border;                                                                     // Nodes on border.
  std::vector<size_t>   side_x;                                                                     // Nodes on "x" side.
  std::vector<size_t>   side_y;                                                                     // Nodes on "y" side.
  float                 x_min              = -1.0f;                                                 // "x_min" spatial boundary [m].
  float                 x_max              = +1.0f;                                                 // "x_max" spatial boundary [m].
  float                 y_min              = -1.0f;                                                 // "y_min" spatial boundary [m].
  float                 y_max              = +1.0f;                                                 // "y_max" spatial boundary [m].
  size_t                side_x_nodes;                                                               // Number of nodes in "x" direction [#].
  size_t                side_y_nodes;                                                               // Number of nodes in "x" direction [#].
  float                 dx;                                                                         // x-axis mesh spatial size [m].
  float                 dy;                                                                         // y-axis mesh spatial size [m].
  float                 link_x;                                                                     // Link "x" component...
  float                 link_y;                                                                     // Link "y" component...
  float                 link_z;                                                                     // Link "z" component...
  float                 pos_x;                                                                      // Position "x" component...
  float                 pos_y;                                                                      // Position "y" component...
  float                 pos_z;                                                                      // Position "z" component...

  // SIMULATION PARAMETERS:
  float                 h   = 0.01f;                                                                // Cloth's thickness [m].
  float                 rho = 1000.0f;                                                              // Cloth's mass density [kg/m^3].
  float                 E   = 100000.0f;                                                            // Cloth's Young modulus [kg/(m*s^2)].
  float                 mu  = 3000.0f;                                                              // Cloth's viscosity [Pa*s].
  float                 g   = 9.81f;                                                                // External gravity field [m/s^2].

  // SIMULATION VARIABLES:
  float                 m;                                                                          // Cloth's mass [kg].
  float                 K;                                                                          // Cloth's elastic constant [kg/s^2].
  float                 B;                                                                          // Cloth's damping [kg*s*m].
  float                 dt_critical;                                                                // Critical time step [s].
  float                 dt_simulation;                                                              // Simulation time step [s].

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////// DATA INITIALIZATION //////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  // MESH:
  cloth->init (nu, std::string (GMSH_HOME) + std::string (GMSH_MESH));                              // Initializing cloth mesh...
  nodes         = cloth->node.size ();                                                              // Getting number of nodes...
  elements      = cloth->element.size ();                                                           // Getting number of elements...
  border        = cloth->physical (1, 1);                                                           // Getting nodes on border...
  side_x        = cloth->physical (1, 2);                                                           // Getting nodes on side_x...
  side_y        = cloth->physical (1, 3);                                                           // Getting nodes on side_y...
  border_nodes  = border.size ();                                                                   // Getting number of nodes on border...
  side_x_nodes  = side_x.size ();                                                                   // Getting number of nodes on side_x...
  side_y_nodes  = side_y.size ();                                                                   // Getting number of nodes on side_y...
  dx            = (x_max - x_min)/(side_x_nodes - 1);                                               // x-axis mesh spatial size [m].
  dy            = (y_max - y_min)/(side_y_nodes - 1);                                               // y-axis mesh spatial size [m].
  m             = rho*h*dx*dy;                                                                      // Node mass [kg].
  K             = E*h*dy/dx;                                                                        // Elastic constant [kg/s^2].
  B             = mu*h*dx*dy;                                                                       // Damping [kg*s*m].
  dt_critical   = sqrt (m/K);                                                                       // Critical time step [s].
  dt_simulation = 0.5*dt_critical;                                                                  // Simulation time step [s].

  // SETTING KERNEL DIMENSIONS:
  kernel_sx     = nodes;                                                                            // Setting OpenCL kernel "x" dimension...
  kernel_sy     = 0;                                                                                // Setting OpenCL kernel "y" dimension...
  kernel_sz     = 0;                                                                                // Setting OpenCL kernel "z" dimension...

  // SETTING NEUTRINO ARRAYS (parameters):
  gravity->data.push_back ({0.0f, 0.0f, -g, 1.0f});                                                 // Setting gravity...
  friction->data.push_back (B);                                                                     // Setting friction...
  dt->data.push_back (dt_simulation);                                                               // Setting time step...

  // SETTING NEUTRINO ARRAYS ("nodes" depending):
  for(i = 0; i < nodes; i++)
  {
    pos_x = cloth->node[i].x;                                                                       // Getting cloth node "x" position...
    pos_y = cloth->node[i].y;                                                                       // Getting cloth node "y" position...
    pos_z = cloth->node[i].z;                                                                       // Getting cloth node "z" position...
    color->data.push_back ({1.0f, 0.0f, 0.0f, 1.0f});                                               // Setting color...
    position->data.push_back ({pos_x, pos_y, pos_z, 1.0f});                                         // Setting position...
    position_int->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                        // Setting intermediate position...
    velocity->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                            // Setting velocity...
    velocity_int->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                        // Setting intermediate velocity...
    acceleration->data.push_back ({0.0f, 0.0f, -g, 1.0f});                                          // Setting acceleration...
    mass->data.push_back (m);                                                                       // Setting "x" mass...
    freedom->data.push_back (1);                                                                    // Setting freedom flag...
  }

  // BUILDING NEIGHBOUR AND OFFSET TUPLES:
  neighbours = 0;                                                                                   // Resetting number of neighbours...

  for(i = 0; i < nodes; i++)
  {
    neighbourhood = cloth->neighbours (i);                                                          // Getting neighbourhood indices...
    neighbour->data.insert (neighbour->data.end (), neighbourhood.begin (), neighbourhood.end ());  // Building neighbour tuple...
    neighbours   += neighbourhood.size ();                                                          // Counting neighbour nodes...
    offset->data.push_back (neighbours);                                                            // Setting neighbour offset...
  }

  for(i = 0; i < nodes; i++)
  {
    j_max = offset->data[i];                                                                        // Setting stride maximum...

    if(i == 0)
    {
      j_min = 0;                                                                                    // Setting stride minimum (first stride)...
    }
    else
    {
      j_min = offset->data[i - 1];                                                                  // Setting stride minimum (all others)...
    }

    for(j = j_min; j < j_max; j++)
    {
      k      = neighbour->data[j];                                                                  // Getting neighbour index...
      link_x = position->data[k].x - position->data[i].x;                                           // Computing link "x" component...
      link_y = position->data[k].y - position->data[i].y;                                           // Computing link "y" component...
      link_z = position->data[k].z - position->data[i].z;                                           // Computing link "z" component...
      resting->data.push_back (
                               sqrt (
                                     pow (
                                          link_x,
                                          2
                                         ) +
                                     pow (link_y, 2) + pow (link_z, 2)
                                    )
                              );                                                                    // Computing resting distace...
      stiffness->data.push_back (K);                                                                // Setting stiffness...
    }
  }

  // ANCHORING BORDER NODES:
  for(int i = 0; i < border_nodes; i++)
  {
    freedom->data[i] = 0;                                                                           // Resetting freedom flag...
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////// NEUTRINO INITIALIZATION /////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  gl->neutrino::init (QUEUE_NUM, KERNEL_NUM);                                                       // Initializing Neutrino baseline...
  gl->init (nu, GUI_SX, GUI_SY, GUI_NAME, orbit_x0, orbit_y0, pan_x0, pan_y0, pan_z0);              // Initializing Neutrino gl...
  cl->init (nu, gl, NU_GPU);                                                                        // Initializing OpenCL context...
  Q->init (nu);                                                                                     // Initializing OpenCL queue...
  K1->init (nu, kernel_sx, kernel_sy, kernel_sz);                                                   // Initializing OpenCL kernel K1...
  K2->init (nu, kernel_sx, kernel_sy, kernel_sz);                                                   // Initializing OpenCL kernel K1...
  S->init (nu);                                                                                     // Initializing OpenGL shader...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENCL KERNELS INITIALIZATION /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  K1->addsource (std::string (KERNEL_HOME) + std::string (KERNEL_1));                               // Setting kernel source file...
  K1->build ();                                                                                     // Building kernel program...

  K2->addsource (std::string (KERNEL_HOME) + std::string (KERNEL_2));                               // Setting kernel source file...
  K2->build ();                                                                                     // Building kernel program...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENGL SHADERS INITIALIZATION /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_VERT), NU_VERTEX);                  // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_GEOM_1), NU_GEOMETRY);              // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_GEOM_2), NU_GEOMETRY);              // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_FRAG), NU_FRAGMENT);                // Setting shader source file...
  S->build ();                                                                                      // Building shader program...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// SETTING OPENCL KERNEL ARGUMENTS /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  for(i = 0; i < data.size (); i++)
  {
    switch(data[i]->type)
    {
      case NU_INT:
        ((nu_int*)data[i])->name    = std::string ("arg_") + std::to_string (i);
        S->setarg ((nu_int*)data[i], i);
        K1->setarg ((nu_int*)data[i], i);
        K2->setarg ((nu_int*)data[i], i);
        Q->write ((nu_int*)data[i], i);
        break;

      case NU_INT2:
        ((nu_int2*)data[i])->name   = std::string ("arg_") + std::to_string (i);
        S->setarg ((nu_int2*)data[i], i);
        K1->setarg ((nu_int2*)data[i], i);
        K2->setarg ((nu_int2*)data[i], i);
        Q->write ((nu_int2*)data[i], i);
        break;

      case NU_INT3:
        ((nu_int3*)data[i])->name   = std::string ("arg_") + std::to_string (i);
        S->setarg ((nu_int3*)data[i], i);
        K1->setarg ((nu_int3*)data[i], i);
        K2->setarg ((nu_int3*)data[i], i);
        Q->write ((nu_int3*)data[i], i);
        break;

      case NU_INT4:
        ((nu_int4*)data[i])->name   = std::string ("arg_") + std::to_string (i);
        S->setarg ((nu_int4*)data[i], i);
        K1->setarg ((nu_int4*)data[i], i);
        K2->setarg ((nu_int4*)data[i], i);
        Q->write ((nu_int4*)data[i], i);
        break;

      case NU_FLOAT:
        ((nu_float*)data[i])->name  = std::string ("arg_") + std::to_string (i);
        S->setarg ((nu_float*)data[i], i);
        K1->setarg ((nu_float*)data[i], i);
        K2->setarg ((nu_float*)data[i], i);
        Q->write ((nu_float*)data[i], i);
        break;

      case NU_FLOAT2:
        ((nu_float2*)data[i])->name = std::string ("arg_") + std::to_string (i);
        S->setarg ((nu_float2*)data[i], i);
        K1->setarg ((nu_float2*)data[i], i);
        K2->setarg ((nu_float2*)data[i], i);
        Q->write ((nu_float2*)data[i], i);
        break;

      case NU_FLOAT3:
        ((nu_float3*)data[i])->name = std::string ("arg_") + std::to_string (i);
        S->setarg ((nu_float3*)data[i], i);
        K1->setarg ((nu_float3*)data[i], i);
        K2->setarg ((nu_float3*)data[i], i);
        Q->write ((nu_float3*)data[i], i);
        break;

      case NU_FLOAT4:
        ((nu_float4*)data[i])->name = std::string ("arg_") + std::to_string (i);
        S->setarg ((nu_float4*)data[i], i);
        K1->setarg ((nu_float4*)data[i], i);
        K2->setarg ((nu_float4*)data[i], i);
        Q->write ((nu_float4*)data[i], i);
        break;
    }
  }

  // EZOR: this is the problem:
  S->size = 11827;

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////// APPLICATION LOOP ////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  while(!gl->closed ())                                                                             // Opening window...
  {
    nu->get_tic ();                                                                                 // Getting "tic" [us]...

    gl->clear ();                                                                                   // Clearing gl...
    gl->poll_events ();                                                                             // Polling gl events...

    for(i = 0; i < data.size (); i++)
    {
      switch(data[i]->type)
      {
        case NU_INT:
          Q->acquire ((nu_int*)data[i], i);
          break;

        case NU_INT2:
          Q->acquire ((nu_int2*)data[i], i);
          break;

        case NU_INT3:
          Q->acquire ((nu_int3*)data[i], i);
          break;

        case NU_INT4:
          Q->acquire ((nu_int4*)data[i], i);
          break;

        case NU_FLOAT:
          Q->acquire ((nu_float*)data[i], i);
          break;

        case NU_FLOAT2:
          Q->acquire ((nu_float2*)data[i], i);
          break;

        case NU_FLOAT3:
          Q->acquire ((nu_float3*)data[i], i);
          break;

        case NU_FLOAT4:
          Q->acquire ((nu_float4*)data[i], i);
          break;
      }
    }

    cl->execute (K1, Q, NU_WAIT);                                                                   // Executing OpenCL kernel...
    cl->execute (K2, Q, NU_WAIT);                                                                   // Executing OpenCL kernel...

    for(i = 0; i < data.size (); i++)
    {
      switch(data[i]->type)
      {
        case NU_INT:
          Q->release ((nu_int*)data[i], i);
          break;

        case NU_INT2:
          Q->release ((nu_int2*)data[i], i);
          break;

        case NU_INT3:
          Q->release ((nu_int3*)data[i], i);
          break;

        case NU_INT4:
          Q->release ((nu_int4*)data[i], i);
          break;

        case NU_FLOAT:
          Q->release ((nu_float*)data[i], i);
          break;

        case NU_FLOAT2:
          Q->release ((nu_float2*)data[i], i);
          break;

        case NU_FLOAT3:
          Q->release ((nu_float3*)data[i], i);
          break;

        case NU_FLOAT4:
          Q->release ((nu_float4*)data[i], i);
          break;
      }
    }

    gl->mouse_navigation (
                          mouse_orbit_rate,                                                         // Orbit angular rate coefficient [rev/s].
                          mouse_pan_rate,                                                           // Pan translation rate [m/s].
                          mouse_decaytime                                                           // Orbit low pass decay time [s].
                         );

    gl->gamepad_navigation (
                            gamepad_orbit_rate,                                                     // Orbit angular rate coefficient [rev/s].
                            gamepad_pan_rate,                                                       // Pan translation rate [m/s].
                            gamepad_decaytime,                                                      // Low pass filter decay time [s].
                            gamepad_deadzone                                                        // Gamepad joystick deadzone [0...1].
                           );

    if(gl->button_CROSS)
    {
      gl->close ();                                                                                 // Closing gl...
    }

    gl->plot (S);                                                                                   // Plotting shared arguments...
    gl->refresh ();                                                                                 // Refreshing gl...
    nu->get_toc ();                                                                                 // Getting "toc" [us]...
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////// CLEANUP ////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  delete nu;                                                                                        // Deleting Neutrino baseline...
  delete gl;                                                                                        // Deleting OpenGL gl...
  delete cl;                                                                                        // Deleting OpenCL context...

  delete color;                                                                                     // Deleting color data...
  delete position;                                                                                  // Deleting position data...
  delete position_int;                                                                              // Deleting intermediate position data...
  delete velocity;                                                                                  // Deleting velocity data...
  delete velocity_int;                                                                              // Deleting intermediate velocity data...
  delete acceleration;                                                                              // Deleting acceleration data...
  delete gravity;                                                                                   // Deleting gravity data...
  delete stiffness;                                                                                 // Deleting stiffness data...
  delete resting;                                                                                   // Deleting resting data...
  delete friction;                                                                                  // Deleting friction data...
  delete mass;                                                                                      // Deleting mass data...
  delete neighbour;                                                                                 // Deleting neighbours...
  delete offset;                                                                                    // Deleting offset...
  delete freedom;                                                                                   // Deleting freedom flag data...
  delete dt;                                                                                        // Deleting time step data...

  delete Q;                                                                                         // Deleting OpenCL queue...
  delete K1;                                                                                        // Deleting OpenCL kernel...
  delete K2;                                                                                        // Deleting OpenCL kernel...

  return 0;
}
