# Install script for directory: /Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/build/mac/gravity")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/build/mac" TYPE EXECUTABLE FILES "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/cmake/gravity")
  if(EXISTS "$ENV{DESTDIR}/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/build/mac/gravity" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/build/mac/gravity")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/glfw/lib-macos"
      "$ENV{DESTDIR}/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/build/mac/gravity")
    execute_process(COMMAND /usr/bin/install_name_tool
      -add_rpath "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/glfw/lib-macos"
      "$ENV{DESTDIR}/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/build/mac/gravity")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/build/mac/gravity")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/Users/Erik/Documents/PROJECTS/BookhouseBoys/ezor/NeutrinoCodes/Examples/Gravity/Code/cmake/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
