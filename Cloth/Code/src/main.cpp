/// @file

#define INTEROP       true                                                                          // "true" = use OpenGL-OpenCL interoperability.
#define SX            800                                                                           // Window x-size [px].
#define SY            600                                                                           // Window y-size [px].
#define NAME          "Neutrino - Cloth"                                                            // Window name.
#define OX            0.0f                                                                          // x-axis orbit initial rotation.
#define OY            0.0f                                                                          // y-axis orbit initial rotation.
#define PX            0.0f                                                                          // x-axis pan initial translation.
#define PY            0.0f                                                                          // y-axis pan initial translation.
#define PZ            -2.0f                                                                         // z-axis pan initial translation.

#define SURFACE_TAG   2                                                                             // Surface tag.
#define BORDER_TAG    6                                                                             // Border tag.
#define SIDE_X_TAG    7                                                                             // Side "x" tag.
#define SIDE_Y_TAG    8                                                                             // Side "y" tag.
#define SURFACE_DIM   2                                                                             // Surface dimension.
#define BORDER_DIM    1                                                                             // Border dimension.
#define SIDE_X_DIM    1                                                                             // Side "x" dimension.
#define SIDE_Y_DIM    1                                                                             // Side "y" dimension.
#define DS            0.05                                                                          // Cloth elementary cell side.
#define EPSILON       0.01                                                                          // Tolerance for cell detection.
#define CELL_VERTICES 4                                                                             // Number of vertices per elementary cell.

#ifdef __linux__
  #define SHADER_HOME "../../Cloth/Code/shader/"                                                    // Linux OpenGL shaders directory.
  #define KERNEL_HOME "../../Cloth/Code/kernel/"                                                    // Linux OpenCL kernels directory.
  #define GMSH_HOME   "../../Cloth/Code/mesh/"                                                      // Linux GMSH mesh directory.
#endif

#ifdef WIN32
  #define SHADER_HOME "..\\..\\Cloth\\Code\\shader\\"                                               // Windows OpenGL shaders directory.
  #define KERNEL_HOME "..\\..\\Cloth\\Code\\kernel\\"                                               // Windows OpenCL kernels directory.
  #define GMSH_HOME   "..\\..\\Cloth\\Code\\mesh\\"                                                 // Linux GMSH mesh directory.
#endif

#define SHADER_VERT   "voxel_vertex.vert"                                                           // OpenGL vertex shader.
#define SHADER_GEOM   "voxel_geometry.geom"                                                         // OpenGL geometry shader.
#define SHADER_FRAG   "voxel_fragment.frag"                                                         // OpenGL fragment shader.
#define KERNEL_1      "thekernel_1.cl"                                                              // OpenCL kernel source.
#define KERNEL_2      "thekernel_2.cl"                                                              // OpenCL kernel source.
#define UTILITIES     "utilities.cl"                                                                // OpenCL utilities source.
#define MESH_FILE     "Square_quadrangles.msh"                                                      // GMSH mesh.
#define MESH          GMSH_HOME MESH_FILE                                                           // GMSH mesh (full path).

// INCLUDES:
#include "nu.hpp"                                                                                   // Neutrino's header file.

int main ()
{
  // INDICES:
  size_t                           i;                                                               // Index [#].
  size_t                           j;                                                               // Index [#].
  size_t                           j_min;                                                           // Index [#].
  size_t                           j_max;                                                           // Index [#].

  // MOUSE PARAMETERS:
  float                            ms_orbit_rate  = 1.0f;                                           // Orbit rotation rate [rev/s].
  float                            ms_pan_rate    = 5.0f;                                           // Pan translation rate [m/s].
  float                            ms_decaytime   = 1.25f;                                          // Pan LP filter decay time [s].

  // GAMEPAD PARAMETERS:
  float                            gmp_orbit_rate = 1.0f;                                           // Orbit angular rate coefficient [rev/s].
  float                            gmp_pan_rate   = 1.0f;                                           // Pan translation rate [m/s].
  float                            gmp_decaytime  = 1.25f;                                          // Low pass filter decay time [s].
  float                            gmp_deadzone   = 0.30f;                                          // Gamepad joystick deadzone [0...1].

  // OPENGL:
  nu::opengl*                      gl             = new nu::opengl (NAME,SX,SY,OX,OY,PX,PY,PZ);     // OpenGL context.
  nu::shader*                      S              = new nu::shader ();                              // OpenGL shader program.
  nu::projection_mode              proj_mode      = nu::MONOCULAR;                                  // OpenGL projection mode.

  // OPENCL:
  nu::opencl*                      cl             = new nu::opencl (nu::GPU);                       // OpenCL context.
  nu::kernel*                      K1             = new nu::kernel ();                              // OpenCL kernel array.
  nu::kernel*                      K2             = new nu::kernel ();                              // OpenCL kernel array.
  nu::float4*                      color          = new nu::float4 (0);                             // Color [].
  nu::float4*                      position       = new nu::float4 (1);                             // Position [m].
  nu::float4*                      velocity       = new nu::float4 (2);                             // Velocity [m/s].
  nu::float4*                      acceleration   = new nu::float4 (3);                             // Acceleration [m/s^2].
  nu::float4*                      position_int   = new nu::float4 (4);                             // Position (intermediate) [m].
  nu::float4*                      velocity_int   = new nu::float4 (5);                             // Velocity (intermediate) [m/s].
  nu::float4*                      gravity        = new nu::float4 (6);                             // Gravity [m/s^2].
  nu::float1*                      stiffness      = new nu::float1 (7);                             // Stiffness.
  nu::float1*                      resting        = new nu::float1 (8);                             // Resting.
  nu::float1*                      friction       = new nu::float1 (9);                             // Friction.
  nu::float1*                      mass           = new nu::float1 (10);                            // Mass [kg].
  nu::int1*                        central        = new nu::int1 (11);                              // Central nodes.
  nu::int1*                        neighbour      = new nu::int1 (12);                              // Neighbour.
  nu::int1*                        offset         = new nu::int1 (13);                              // Offset.
  nu::int1*                        freedom        = new nu::int1 (14);                              // Freedom.
  nu::float1*                      dt             = new nu::float1 (15);                            // Time step [s].

  // MESH:
  nu::mesh*                        cloth          = new nu::mesh (MESH);                            // Mesh cloth.
  size_t                           nodes;                                                           // Number of nodes.
  size_t                           elements;                                                        // Number of elements.
  size_t                           groups;                                                          // Number of groups.
  size_t                           neighbours;                                                      // Number of neighbours.
  std::vector<size_t>              side_x;                                                          // Nodes on "x" side.
  std::vector<size_t>              side_y;                                                          // Nodes on "y" side.
  std::vector<GLint>               border;                                                          // Nodes on border.
  size_t                           side_x_nodes;                                                    // Number of nodes in "x" direction [#].
  size_t                           side_y_nodes;                                                    // Number of nodes in "x" direction [#].
  size_t                           border_nodes;                                                    // Number of border nodes.
  float                            x_min = -1.0f;                                                   // "x_min" spatial boundary [m].
  float                            x_max = +1.0f;                                                   // "x_max" spatial boundary [m].
  float                            y_min = -1.0f;                                                   // "y_min" spatial boundary [m].
  float                            y_max = +1.0f;                                                   // "y_max" spatial boundary [m].
  float                            dx;                                                              // x-axis mesh spatial size [m].
  float                            dy;                                                              // y-axis mesh spatial size [m].

  // SIMULATION PARAMETERS:
  float                            h     = 0.01f;                                                   // Cloth's thickness [m].
  float                            rho   = 1000.0f;                                                 // Cloth's mass density [kg/m^3].
  float                            E     = 10000.0f;                                                // Cloth's Young modulus [kg/(m*s^2)].
  float                            mu    = 1000.0f;                                                 // Cloth's viscosity [Pa*s].
  float                            g     = 9.81f;                                                   // External gravity field [m/s^2].

  // SIMULATION VARIABLES:
  float                            m;                                                               // Cloth's mass [kg].
  float                            K;                                                               // Cloth's elastic constant [kg/s^2].
  float                            B;                                                               // Cloth's damping [kg*s*m].
  float                            dt_critical;                                                     // Critical time step [s].
  float                            dt_simulation;                                                   // Simulation time step [s].

  // BACKUP:
  std::vector<nu_float4_structure> initial_position;                                                // Backing up initial data...
  std::vector<nu_float4_structure> initial_position_int;                                            // Backing up initial data...
  std::vector<nu_float4_structure> initial_velocity;                                                // Backing up initial data...
  std::vector<nu_float4_structure> initial_velocity_int;                                            // Backing up initial data...
  std::vector<nu_float4_structure> initial_acceleration;                                            // Backing up initial data...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////// DATA INITIALIZATION ///////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  // MESH "X" SIDE:
  cloth->process (SIDE_X_TAG, SIDE_X_DIM, nu::MSH_PNT);                                             // Processing mesh...
  side_x_nodes    = cloth->node.size ();                                                            // Getting number of nodes along "x" side...

  // MESH "Y" SIDE:
  cloth->process (SIDE_Y_TAG, SIDE_Y_DIM, nu::MSH_PNT);                                             // Processing mesh...
  side_y_nodes    = cloth->node.size ();                                                            // Getting number of nodes along "y" side...

  // COMPUTING PHYSICAL PARAMETERS:
  dx              = (x_max - x_min)/(side_x_nodes - 1);                                             // x-axis mesh spatial size [m].
  dy              = (y_max - y_min)/(side_y_nodes - 1);                                             // y-axis mesh spatial size [m].
  m               = rho*h*dx*dy;                                                                    // Node mass [kg].
  K               = E*h*dy/dx;                                                                      // Elastic constant [kg/s^2].
  B               = mu*h*dx*dy;                                                                     // Damping [kg*s*m].
  dt_critical     = sqrt (m/K);                                                                     // Critical time step [s].
  dt_simulation   = 0.5f*dt_critical;                                                               // Simulation time step [s].
  dt->data.push_back (dt_simulation);                                                               // Setting simulation time step...
  friction->data.push_back (B);                                                                     // Setting friction...
  gravity->data.push_back ({0.0f, 0.0f, -g, 1.0f});                                                 // Setting gravity...

  // MESH SURFACE:
  cloth->process (SURFACE_TAG, SURFACE_DIM, nu::MSH_QUA_4);                                         // Processing mesh...
  position->data  = cloth->node_coordinates;                                                        // Setting all node coordinates...
  neighbour->data = cloth->neighbour;                                                               // Setting neighbour indices...
  offset->data    = cloth->neighbour_offset;                                                        // Setting neighbour offsets...
  resting->data   = cloth->neighbour_length;                                                        // Setting resting distances...
  nodes           = cloth->node.size ();                                                            // Getting the number of nodes...
  elements        = cloth->element.size ();                                                         // Getting the number of elements...
  groups          = cloth->group.size ();                                                           // Getting the number of groups...
  neighbours      = cloth->neighbour.size ();                                                       // Getting the number of neighbours...
  std::cout << "nodes = " << nodes << std::endl;                                                    // Printing message...
  std::cout << "elements = " << elements/CELL_VERTICES << std::endl;                                // Printing message...
  std::cout << "groups = " << groups/CELL_VERTICES << std::endl;                                    // Printing message...
  std::cout << "neighbours = " << neighbours << std::endl;                                          // Printing message...

  // SETTING NEUTRINO ARRAYS ("surface" depending):
  for(i = 0; i < nodes; i++)
  {
    std::cout << "i = " << i << ", node index = " << cloth->node[i] << ", neighbour indices:";      // Printing message...
    position_int->data.push_back (position->data[i]);                                               // Setting initial intermediate position...
    velocity->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                            // Setting initial velocity...
    velocity_int->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                        // Setting initial intermediate velocity...
    acceleration->data.push_back ({0.0f, 0.0f, 0.0f, 1.0f});                                        // Setting initial acceleration...
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
      central->data.push_back (cloth->node[i]);                                                     // Building central node tuple...
      stiffness->data.push_back (K);                                                                // Setting link stiffness...

      std::cout << " " << neighbour->data[j];                                                       // Printing message...

      if(resting->data[j] > (DS + EPSILON))
      {
        color->data.push_back ({1.0f, 0.0f, 0.0f, 0.1f});                                           // Setting link color...
      }
      else
      {
        color->data.push_back ({0.0f, 1.0f, 0.0f, 1.0f});                                           // Setting link color...
      }
    }

    std::cout << std::endl;                                                                         // Printing message...
  }

  // MESH BORDER:
  cloth->process (BORDER_TAG, BORDER_DIM, nu::MSH_PNT);                                             // Processing mesh...
  border               = cloth->node;                                                               // Getting nodes on border...
  border_nodes         = border.size ();                                                            // Getting the number of nodes on border...

  // SETTING NEUTRINO ARRAYS ("border" depending):
  for(i = 0; i < border_nodes; i++)
  {
    freedom->data[border[i]] = 0;                                                                   // Resetting freedom flag...
  }

  // SETTING INITIAL DATA BACKUP:
  initial_position     = position->data;                                                            // Setting backup data...
  initial_position_int = position_int->data;                                                        // Setting backup data...
  initial_velocity     = velocity->data;                                                            // Setting backup data...
  initial_velocity_int = velocity_int->data;                                                        // Setting backup data...
  initial_acceleration = acceleration->data;                                                        // Setting backup data...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENCL KERNELS INITIALIZATION //////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  K1->addsource (std::string (KERNEL_HOME) + std::string (UTILITIES));                              // Setting kernel source file...
  K1->addsource (std::string (KERNEL_HOME) + std::string (KERNEL_1));                               // Setting kernel source file...
  K1->build (nodes, 0, 0);                                                                          // Building kernel program...
  K2->addsource (std::string (KERNEL_HOME) + std::string (UTILITIES));                              // Setting kernel source file...
  K2->addsource (std::string (KERNEL_HOME) + std::string (KERNEL_2));                               // Setting kernel source file...
  K2->build (nodes, 0, 0);                                                                          // Building kernel program...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// OPENGL SHADERS INITIALIZATION //////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_VERT), nu::VERTEX);                 // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_GEOM), nu::GEOMETRY);               // Setting shader source file...
  S->addsource (std::string (SHADER_HOME) + std::string (SHADER_FRAG), nu::FRAGMENT);               // Setting shader source file...
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
    cl->execute (K1, nu::WAIT);                                                                     // Executing OpenCL kernel...
    cl->execute (K2, nu::WAIT);                                                                     // Executing OpenCL kernel...
    cl->release ();                                                                                 // Releasing OpenCL kernel...

    gl->clear ();                                                                                   // Clearing gl...
    gl->poll_events ();                                                                             // Polling gl events...
    gl->mouse_navigation (ms_orbit_rate, ms_pan_rate, ms_decaytime);                                // Polling mouse...
    gl->gamepad_navigation (gmp_orbit_rate, gmp_pan_rate, gmp_decaytime, gmp_deadzone);             // Polling gamepad...
    gl->plot (S, proj_mode);                                                                        // Plotting shared arguments...

    ImGui_ImplOpenGL3_NewFrame ();                                                                  // Initializing ImGui...
    ImGui_ImplGlfw_NewFrame ();                                                                     // Initializing ImGui...
    ImGui::NewFrame ();                                                                             // Initializing ImGui...

    ImGui::Begin ("FREE LATTICE PARAMETERS", NULL, ImGuiWindowFlags_AlwaysAutoResize);              // Beginning window...
    ImGui::PushItemWidth (200);                                                                     // Setting window width [px]...

    ImGui::PushStyleColor (ImGuiCol_Text, IM_COL32 (0,255,0,255));                                  // Setting text color...
    ImGui::Text ("Thickness:       ");                                                              // Writing text...
    ImGui::PopStyleColor ();                                                                        // Restoring text color...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::Text ("h =   ");                                                                         // Writing text...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::InputFloat (" [m]", &h);                                                                 // Adding input field...

    ImGui::PushStyleColor (ImGuiCol_Text, IM_COL32 (0,255,0,255));                                  // Setting text color...
    ImGui::Text ("Mass density:    ");                                                              // Writing text...
    ImGui::PopStyleColor ();                                                                        // Restoring text color...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::Text ("rho = ");                                                                         // Writing text...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::InputFloat (" [kg/m^3]", &rho);                                                          // Adding input field...

    ImGui::PushStyleColor (ImGuiCol_Text, IM_COL32 (0,255,0,255));                                  // Setting text color...
    ImGui::Text ("Young's modulus: ");                                                              // Writing text...
    ImGui::PopStyleColor ();                                                                        // Restoring text color...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::Text ("E =   ");                                                                         // Writing text...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::InputFloat (" [kg/(m*s^2)]", &E);                                                        // Adding input field...

    ImGui::PushStyleColor (ImGuiCol_Text, IM_COL32 (0,255,0,255));                                  // Setting text color...
    ImGui::Text ("Viscosity:       ");                                                              // Writing text...
    ImGui::PopStyleColor ();                                                                        // Restoring text color...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::Text ("mu =  ");                                                                         // Writing text...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::InputFloat (" [Pa*s]", &mu);                                                             // Adding input field...

    ImGui::PushStyleColor (ImGuiCol_Text, IM_COL32 (0,255,0,255));                                  // Setting text color...
    ImGui::Text ("Gravity:         ");                                                              // Writing text...
    ImGui::PopStyleColor ();                                                                        // Restoring text color...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::Text ("g =   ");                                                                         // Writing text...
    ImGui::SameLine ();                                                                             // Staying on same line...
    ImGui::InputFloat (" [m/s^2]", &g);                                                             // Adding input field...

    if(ImGui::Button ("Update"))
    {
      // RECOMPUTING PHYSICAL PARAMETERS:
      m                 = rho*h*dx*dy;                                                              // Node mass [kg].
      K                 = E*h*dy/dx;                                                                // Elastic constant [kg/s^2].
      B                 = mu*h*dx*dy;                                                               // Damping [kg*s*m].
      dt_critical       = sqrt (m/K);                                                               // Critical time step [s].
      dt_simulation     = 0.5f*dt_critical;                                                         // Simulation time step [s].
      dt->data[0]       = dt_simulation;                                                            // Setting simulation time step...
      friction->data[0] = B;                                                                        // Setting friction...
      gravity->data[0]  = {0.0f, 0.0f, -g, 1.0f};                                                   // Setting gravity...

      // RESETTING NEUTRINO ARRAYS ("surface" depending):
      for(i = 0; i < nodes; i++)
      {
        mass->data[i] = m;                                                                          // Setting mass...

        // Computing minimum element offset index:
        if(i == 0)
        {
          j_min = 0;                                                                                // Setting minimum element offset index...
        }
        else
        {
          j_min = offset->data[i - 1];                                                              // Setting minimum element offset index...
        }

        j_max         = offset->data[i];                                                            // Setting maximum element offset index...

        for(j = j_min; j < j_max; j++)
        {
          stiffness->data[j] = K;                                                                   // Setting link stiffness...
        }
      }

      cl->write (6);                                                                                // Writing OpenCL data...
      cl->write (7);                                                                                // Writing OpenCL data...
      cl->write (9);                                                                                // Writing OpenCL data...
      cl->write (10);                                                                               // Writing OpenCL data...
      cl->write (15);                                                                               // Writing OpenCL data...
    }

    ImGui::End ();                                                                                  // Finishing window...

    ImGui::Render ();                                                                               // Rendering windows...
    ImGui_ImplOpenGL3_RenderDrawData (ImGui::GetDrawData ());                                       // Rendering windows...

    gl->refresh ();                                                                                 // Refreshing gl...

    if(gl->button_TRIANGLE || gl->key_R)
    {
      position->data     = initial_position;                                                        // Restoring backup...
      position_int->data = initial_position_int;                                                    // Restoring backup...
      velocity->data     = initial_velocity;                                                        // Restoring backup...
      velocity_int->data = initial_velocity_int;                                                    // Restoring backup...
      acceleration->data = initial_acceleration;                                                    // Restoring backup...
      cl->write (1);                                                                                // Writing data...
      cl->write (2);                                                                                // Writing data...
      cl->write (3);                                                                                // Writing data...
      cl->write (4);                                                                                // Writing data...
      cl->write (5);                                                                                // Writing data...
    }

    if(gl->key_M)
    {
      proj_mode = nu::MONOCULAR;                                                                    // Setting monocular projection...
    }

    if(gl->key_B)
    {
      proj_mode = nu::BINOCULAR;                                                                    // Setting binocular projection...
    }

    if(gl->button_CROSS || gl->key_ESCAPE)
    {
      gl->close ();                                                                                 // Closing gl...
    }

    cl->get_toc ();                                                                                 // Getting "toc" [us]...
  }

  ImGui_ImplOpenGL3_Shutdown ();                                                                    // Deinitializing ImGui...
  ImGui_ImplGlfw_Shutdown ();                                                                       // Deinitializing ImGui...
  ImGui::DestroyContext ();                                                                         // Deinitializing ImGui...

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////// CLEANUP /////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  delete cl;                                                                                        // Deleting OpenCL context...
  delete gl;                                                                                        // Deleting OpenGL context...
  delete S;                                                                                         // Deleting shader...
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
  delete central;                                                                                   // Deleting centrals...
  delete neighbour;                                                                                 // Deleting neighbours...
  delete offset;                                                                                    // Deleting offset...
  delete freedom;                                                                                   // Deleting freedom flag data...
  delete dt;                                                                                        // Deleting time step data...
  delete K1;                                                                                        // Deleting OpenCL kernel...
  delete K2;                                                                                        // Deleting OpenCL kernel...
  delete cloth;                                                                                     // deleting cloth mesh...

  return 0;
}
