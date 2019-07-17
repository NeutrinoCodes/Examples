message("Checking cmake version...")
cmake_minimum_required(VERSION 3.0)

message("")
message("################################################################################")
message("##################################### GCC ######################################")
message("################################################################################")
message("")

# Type: "make" in order to build the project.

if(UNIX AND NOT APPLE)
  message("Setting LINUX variable, according to an existing LINUX (but not APPLE) OS...")
  set(LINUX TRUE)
endif()

message("Setting project name...")
project (cloth)

message("Creating a SOURCES variable with a link to all cpp files to compile...")
set(SOURCES

$ENV{NEUTRINO_PATH}/Code/src/device.cpp
$ENV{NEUTRINO_PATH}/Code/src/host_datatypes.cpp
$ENV{NEUTRINO_PATH}/Code/src/kernel.cpp
$ENV{NEUTRINO_PATH}/Code/src/linear_algebra.cpp
$ENV{NEUTRINO_PATH}/Code/src/neutrino.cpp
$ENV{NEUTRINO_PATH}/Code/src/opencl.cpp
$ENV{NEUTRINO_PATH}/Code/src/opengl.cpp
$ENV{NEUTRINO_PATH}/Code/src/platform.cpp
$ENV{NEUTRINO_PATH}/Code/src/projective_geometry.cpp
$ENV{NEUTRINO_PATH}/Code/src/queue.cpp
$ENV{NEUTRINO_PATH}/Code/src/shader.cpp
$ENV{NEUTRINO_PATH}/Code/src/glad.c
${CMAKE_HOME_DIRECTORY}/src/main.cpp)

if(APPLE)
  message("Setting directory for the Mac executable...")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_HOME_DIRECTORY}/build/mac)
endif(APPLE)

if(LINUX)
  message("Setting directory for the Linux executable...")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_HOME_DIRECTORY}/build/linux)
endif(LINUX)

message("Adding an executable with the above sources...")
add_executable(cloth ${SOURCES})

message("Setting the directories that should be included in the build command...")
target_include_directories(cloth PRIVATE $ENV{NEUTRINO_PATH}/Code/include)

if(APPLE)
  message("Setting the Mac libraries that should be linked in the build command...")
  target_link_libraries(cloth "-framework OpenGL" "-framework OpenCL" "-lGLEW" "-lglfw" "-lm")
endif(APPLE)

if(LINUX)
  message("Setting the Linux libraries that should be linked in the build command...")
  target_link_libraries(cloth "-lOpenGL" "-lOpenCL" "-lGLEW" "-lglfw" "-lm")
endif(LINUX)

# Type: "make run" to run the executable.
add_custom_target(run
    WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    COMMAND cloth
    VERBATIM )

message("Limiting number of reported gcc errors...[# = 20]")
set(GCC_MAX_ERRORS "-fmax-errors=20")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${GCC_MAX_ERRORS}")

message("DONE configuring GCC!")

message("")
message("################################################################################")
message("#################################### DOXYGEN ###################################")
message("################################################################################")
message("")

# Type: "make doc" in order to build the Doxygen documentation of the project.

message("Checking whether Doxygen is installed...")
find_package(Doxygen)
if (DOXYGEN_FOUND)
    message("Setting input and output files...")
    set(DOXYGEN_IN ${CMAKE_HOME_DIRECTORY}/../Docs/Doxyfile.in)
    set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

    message("Requesting to configure the file...")
    configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
    message("DONE configuring Doxygen!")

    add_custom_target(doc
        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM )
else (DOXYGEN_FOUND)
  message("Doxygen need to be installed to generate the doxygen documentation!")
endif (DOXYGEN_FOUND)
