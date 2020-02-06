/// @file

// OPENGL:
#define INTEROP    true                                                                             // "true" = use OpenGL-OpenCL interoperability.
#define GUI_SIZE_X 800                                                                              // Window x-size [px].
#define GUI_SIZE_Y 600                                                                              // Window y-size [px].
#define GUI_NAME   "neutrino 3.0"                                                                   // Window name.

#ifdef __linux__
  #define SHADER_HOME \
  "/run/media/ezor/LINUX/BookhouseBoys/ezor/NeutrinoCodes/Examples/Cloth3D/Code/shader"             // Linux OpenGL shaders directory.

  #define KERNEL_HOME \
  "/run/media/ezor/LINUX/BookhouseBoys/ezor/NeutrinoCodes/Examples/Cloth3D/Code/kernel"             // Linux OpenCL kernels directory.
#endif

#ifdef __APPLE__
  #define SHADER_HOME \
  "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Cloth3D/Code/shader"    // Mac OpenGL shaders directory.

  #define KERNEL_HOME \
  "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Cloth3D/Code/kernel"    // Mac OpenCL kernels directory.
#endif

#ifdef WIN32
  #define SHADER_HOME "F:\\BookHouseBoys\\ezor\\NeutrinoCodes\\Examples\\Cloth3D\\Code\\shader"     // Windows OpenGL shaders directory.
  #define KERNEL_HOME "F:\\BookHouseBoys\\ezor\\NeutrinoCodes\\Examples\\Cloth3D\\Code\\kernel"     // Windows OpenCL kernels directory.
#endif

#define SHADER_VERT   "voxel_vertex.vert"                                                           // OpenGL vertex shader.
#define SHADER_GEOM   "voxel_geometry.geom"                                                         // OpenGL geometry shader.
#define SHADER_FRAG   "voxel_fragment.frag"                                                         // OpenGL fragment shader.

// OPENCL:
#define QUEUE_NUM     1                                                                             // # of OpenCL queues [#].
#define KERNEL_NUM    2                                                                             // # of OpenCL kernel [#].

#define KERNEL_F1     "thekernel1.cl"                                                               // OpenCL kernel.

// INCLUDES:
#include "nu.hpp"                                                                                   // Neutrino's header file.

int main ()
{
  // DATA:
  float     x_min               = -1.0;                                                             // "x_min" spatial boundary [m].
  float     x_max               = +1.0;                                                             // "x_max" spatial boundary [m].
  float     y_min               = -1.0;                                                             // "y_min" spatial boundary [m].
  float     y_max               = +1.0;                                                             // "y_max" spatial boundary [m].
  size_t    gid;                                                                                    // Global index [#].

  // GUI PARAMETERS (mouse):
  float     mouse_x             = 0.0;                                                              // x-axis current screen position [px].
  float     mouse_y             = 0.0;                                                              // y-axis current screen position [px].
  float     mouse_z             = 0.0;                                                              // z-axis current screen position [px].
  float     mouse_x_old         = 0.0;                                                              // x-axis old screen position [px].
  float     mouse_y_old         = 0.0;                                                              // y-axis old screen position [px].
  float     mouse_z_old         = 0.0;                                                              // z-axis old screen position [px].
  float     mouse_velocity_x    = 0.0;                                                              // x-axis screen velocity [px/s].
  float     mouse_velocity_y    = 0.0;                                                              // y-axis screen velocity [px/s].
  float     mouse_velocity_z    = 0.0;                                                              // z-axis screen velocity [px/s].
  float     mouse_orbit_rate    = 1.0;                                                              // Orbit rotation rate [rev/s].
  bool      mouse_sample        = false;                                                            // Mouse flag, for velocity computation.
  float     mouse_dt            = 0.0;                                                              // Mouse dt [s].
  float     mouse_dt_min        = 0.01;
  float     mouse_dt_max        = 0.05;
  float     mouse_pan_x_init    = 0.0f;                                                             // x-axis pan initial translation.
  float     mouse_pan_y_init    = 0.0f;                                                             // y-axis pan initial translation.
  float     mouse_pan_z_init    = -2.0f;                                                            // z-axis pan initial translation.
  float     mouse_pan_x         = 0.0;                                                              // x-axis pan translation.
  float     mouse_pan_y         = 0.0;                                                              // y-axis pan translation.
  float     mouse_pan_z         = 0.0;                                                              // z-axis pan translation.
  float     mouse_pan_decaytime = 1.25;                                                             // Pan LP filter decay time [s].
  float     mouse_pan_deadzone  = 0.1;                                                              // Pan translation deadzone [0...1].
  float     mouse_pan_xy_rate   = 10.0;                                                             // Pan xy-translation rate [m/s].
  float     mouse_pan_z_rate    = 5.0;                                                              // Pan z-translation rate [m/s].

  // GUI PARAMETERS (orbit):
  float     orbit_x_init        = 0.0f;                                                             // x-axis orbit initial rotation.
  float     orbit_y_init        = 0.0f;                                                             // y-axis orbit initial rotation.
  float     orbit_x;                                                                                // x-axis orbit rotation.
  float     orbit_y;                                                                                // y-axis orbit rotation.
  float     orbit_decaytime     = 1.25;                                                             // Orbit LP filter decay time [s].
  float     orbit_deadzone      = 0.1;                                                              // Orbit rotation deadzone [0...1].
  float     orbit_rate          = 1.0;                                                              // Orbit rotation rate [rev/s].

  // GUI PARAMETERS (pan):
  float     pan_x_init          = 0.0f;                                                             // x-axis pan initial translation.
  float     pan_y_init          = 0.0f;                                                             // y-axis pan initial translation.
  float     pan_z_init          = -2.0f;                                                            // z-axis pan initial translation.
  float     pan_x;                                                                                  // x-axis pan translation.
  float     pan_y;                                                                                  // y-axis pan translation.
  float     pan_z;                                                                                  // z-axis pan translation.
  float     pan_decaytime       = 1.25;                                                             // Pan LP filter decay time [s].
  float     pan_deadzone        = 0.1;                                                              // Pan translation deadzone [0...1].
  float     pan_rate            = 1.0;                                                              // Pan translation rate [m/s].

  // NEUTRINO:
  neutrino* bas                 = new neutrino ();                                                  // Neutrino baseline.
  opengl*   gui                 = new opengl ();                                                    // OpenGL context.
  opencl*   ctx                 = new opencl ();                                                    // OpenCL context.
  shader*   S                   = new shader ();                                                    // OpenGL shader program.
  queue*    Q                   = new queue ();                                                     // OpenCL queue.
  kernel*   K1                  = new kernel ();                                                    // OpenCL kernel array.

  // MESH:
  mesh*     cloth               = new mesh ();                                                      // Mesh context.                                                                                // Total # of nodes [#].

  // NODE KINEMATICS:
  float4G*  position            = new float4G ();                                                   // Position [m].
  float4G*  color               = new float4G ();                                                   // Depth [m].

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////// DATA INITIALIZATION //////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  cloth->init (bas, "/Users/Erik/Desktop/gmsh_test/cube.msh");                                      // Initializing cloth mesh...
  position->init (cloth->nodes);                                                                    // Initializing position data...
  color->init (cloth->nodes);                                                                       // Initializing depth data...
  cloth->read_msh (position);                                                                       // Reading cloth mesh from file...

  for(gid = 0; gid < cloth->nodes; gid++)
  {
    std::cout << "p.x = " << position->data[gid].x << " "
              << "p.y = " << position->data[gid].y << " "
              << "p.z = " << position->data[gid].z << " "
              << "p.w = " << position->data[gid].w << std::endl;

    color->data[gid].x = 0.01f*(rand () % 100);                                                     // Settin "r" color coordinate...
    color->data[gid].y = 0.01f*(rand () % 100);                                                     // Settin "g" color coordinate...
    color->data[gid].z = 0.01f*(rand () % 100);                                                     // Settin "b" color coordinate...
    color->data[gid].w = 1.0;                                                                       // Settin "a" color coordinate...
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////// NEUTRINO INITIALIZATION /////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  bas->init (QUEUE_NUM, KERNEL_NUM);                                                                // Initializing Neutrino baseline...
  gui->init                                                                                         // Initializing Neutrino GUI...
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
  ctx->init (bas, gui, NU_GPU);                                                                     // Initializing OpenCL context...
  S->init (bas, SHADER_HOME, SHADER_VERT, SHADER_GEOM, SHADER_FRAG);                                // Initializing OpenGL shader...
  Q->init (bas);                                                                                    // Initializing OpenCL queue...

  size_t kernel_sx = cloth->nodes;                                                                  // Kernel dimension "x" [#].
  size_t kernel_sy = 0;                                                                             // Kernel dimension "y" [#].
  size_t kernel_sz = 0;                                                                             // Kernel dimension "z" [#].
  K1->init (bas, KERNEL_HOME, KERNEL_F1, kernel_sx, kernel_sy, kernel_sz);                          // Initializing OpenCL kernel K1...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////// SETTING OPENCL KERNEL ARGUMENTS /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  K1->setarg (position, 0);                                                                         // Setting position kernel argument...
  K1->setarg (color, 1);                                                                            // Setting depth kernel argument...

  position->name = "voxel_center";                                                                  // Setting variable name for OpenGL shader...
  color->name    = "voxel_color";                                                                   // Setting variable name for OpenGL shader...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// WRITING DATA ON OPENCL QUEUE //////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  Q->write (position, 0);                                                                           // Writing position data on queue...
  Q->write (color, 1);                                                                              // Writing depth data on queue...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////// SETTING OPENGL SHADER ARGUMENTS ////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  S->setarg (position, 0);                                                                          // Setting shader argument "0"...
  S->setarg (color, 1);                                                                             // Setting shader argument "1"...
  S->build ();                                                                                      // Building shader program...

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////// APPLICATION LOOP ////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  while(!gui->closed ())                                                                            // Opening window...
  {
    bas->get_tic ();                                                                                // Getting "tic" [us]...

    gui->clear ();                                                                                  // Clearing gui...
    gui->poll_events ();                                                                            // Polling gui events...

    Q->acquire (position, 0);                                                                       // Acquiring OpenGL/CL shared argument...
    Q->acquire (color, 1);                                                                          // Acquiring OpenGL/CL shared argument...
    ctx->execute (K1, Q, NU_WAIT);                                                                  // Executing OpenCL kernel...
    Q->release (position, 0);                                                                       // Releasing OpenGL/CL shared argument...
    Q->release (color, 1);                                                                          // Releasing OpenGL/CL shared argument...

    mouse_x = gui->mouse_X;                                                                         // Getting mouse x-axis...
    mouse_y = gui->mouse_Y;                                                                         // Getting mouse y-axis...
    mouse_z = gui->scroll_Y;                                                                        // Getting mouse x-axis...

    switch(mouse_sample)                                                                            // Sampling mouse position...
    {
      case false:
        mouse_x      = gui->mouse_X;                                                                // Getting mouse x-axis...
        mouse_y      = gui->mouse_Y;                                                                // Getting mouse y-axis...
        mouse_z      = gui->scroll_Y;                                                               // Getting mouse z-axis...
        mouse_sample = true;                                                                        // Setting sample flag...
        break;

      case true:
        mouse_x_old  = mouse_x;                                                                     // Backing up mouse x-axis...
        mouse_y_old  = mouse_y;                                                                     // Backing up mouse y-axis...
        mouse_z_old  = mouse_z;                                                                     // Backing up mouse z-axis...
        mouse_x      = gui->mouse_X;                                                                // Getting mouse x-axis...
        mouse_y      = gui->mouse_Y;                                                                // Getting mouse y-axis...
        mouse_z      = gui->scroll_Y;                                                               // Getting mouse z-axis...
        mouse_sample = false;                                                                       // Resetting sample flag...
        break;
    }

    mouse_dt         = bas->constrain_float (bas->loop_time, mouse_dt_min, mouse_dt_max);           // Getting loop time...
    mouse_velocity_x = +(mouse_x - mouse_x_old)/(gui->window_size_x*mouse_dt);                      // Computing mouse x-velocity [px/s]...
    mouse_velocity_y = -(mouse_y - mouse_y_old)/(gui->window_size_y*mouse_dt);                      // Computing mouse y-velocity [px/s]...
    mouse_velocity_z = +(mouse_z - mouse_z_old)/(gui->window_size_y*mouse_dt);                      // Computing mouse z-velocity [px/s]...
    mouse_pan_x      = mouse_velocity_x;                                                            // Setting world x-pan...
    mouse_pan_y      = mouse_velocity_y;                                                            // Setting world y-pan...
    mouse_pan_z      = mouse_velocity_z;                                                            // Setting world z-pan...

    // Doing mouse pan z-movement...
    gui->pan (
              0.0,                                                                                  // World x-pan.
              0.0,                                                                                  // World y-pan.
              mouse_z,                                                                              // World z-pan.
              mouse_pan_z_rate,                                                                     // Pan rate [length/s].
              mouse_pan_deadzone,                                                                   // Pan deadzone threshold coefficient.
              mouse_pan_decaytime                                                                   // Pan low pass decay time [s].
             );

    // Doing mouse orbit movement...
    if(gui->mouse_LEFT)
    {
      gui->orbit (
                  mouse_velocity_x,                                                                 // "Near clipping-plane" x-coordinate.
                  mouse_velocity_y,                                                                 // "Near clipping-plane" y-coordinate.
                  mouse_orbit_rate,                                                                 // Orbit angular rate coefficient [rev/s].
                  0.0,                                                                              // Orbit deadzone threshold coefficient.
                  orbit_decaytime                                                                   // Orbit low pass decay time [s].
                 );
    }

    // Doing mouse pan xy-movement...
    if(gui->mouse_RIGHT)
    {
      gui->pan (
                mouse_pan_x,                                                                        // World x-pan.
                mouse_pan_y,                                                                        // World y-pan.
                mouse_pan_z,                                                                        // World z-pan.
                mouse_pan_xy_rate,                                                                  // Pan rate [length/s].
                mouse_pan_deadzone,                                                                 // Pan deadzone threshold coefficient.
                mouse_pan_decaytime                                                                 // Pan low pass decay time [s].
               );
    }

    orbit_x = +gui->axis_LEFT_X;                                                                    // Setting "Near clipping-plane" x-coordinate...
    orbit_y = -gui->axis_LEFT_Y;                                                                    // Setting "Near clipping-plane" y-coordinate...

    gui->orbit (
                orbit_x,                                                                            // "Near clipping-plane" x-coordinate.
                orbit_y,                                                                            // "Near clipping-plane" y-coordinate.
                orbit_rate,                                                                         // Orbit angular rate coefficient [rev/s].
                orbit_deadzone,                                                                     // Orbit deadzone threshold coefficient.
                orbit_decaytime                                                                     // Orbit low pass decay time [s].
               );

    pan_x   = +gui->axis_RIGHT_X;                                                                   // Setting world x-pan...
    pan_y   = -gui->axis_RIGHT_Y;                                                                   // Setting world y-pan...
    pan_z   = (gui->axis_RIGHT_TRIGGER + 1.0)/2.0 - (gui->axis_LEFT_TRIGGER + 1.0)/2.0;             // Setting world z-pan...

    gui->pan (
              pan_x,                                                                                // World x-pan.
              pan_y,                                                                                // World y-pan.
              pan_z,                                                                                // World z-pan.
              pan_rate,                                                                             // Pan rate [length/s].
              pan_deadzone,                                                                         // Pan deadzone threshold coefficient.
              pan_decaytime                                                                         // Pan low pass decay time [s].
             );

    if(gui->button_CROSS)
    {
      gui->close ();                                                                                // Closing gui...
    }

    gui->plot (S);                                                                                  // Plotting shared arguments...
    gui->refresh ();                                                                                // Refreshing gui...
    bas->get_toc ();                                                                                // Getting "toc" [us]...
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////// CLEANUP ////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  delete bas;                                                                                       // Deleting Neutrino baseline...
  delete gui;                                                                                       // Deleting OpenGL gui...
  delete ctx;                                                                                       // Deleting OpenCL context...

  delete position;                                                                                  // Deleting position data...
  delete color;                                                                                     // Deleting depth data...

  delete Q;                                                                                         // Deleting OpenCL queue...
  delete K1;                                                                                        // Deleting OpenCL kernel...

  return 0;
}
