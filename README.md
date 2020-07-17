# NEUTRINO EXAMPLES

_A fast and light library for GPU-based computation and interactive data visualization._

[www.neutrino.codes](http://www.neutrino.codes)

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2020

**PLEASE NOTICE THE FOLLOWING LIST OF HARDWARE AND SOFTWARE REQUIREMENTS ARE IN COMMON WITH THOSE
ONES FOR THE INSTALLATION AND USAGE OF THE "NEUTRINO" LIBRARY. PLEASE CHECK THE SAME REQUIREMENTS
HAVE BEEN ALREADY MET DURING THAT INSTALLATION BY READING THE `README.md` FILE IN THE "NEUTRINO"
REPOSITORY: https://github.com/NeutrinoCodes/Neutrino.**

# Overview
The Examples can be successfully installed and used on Linux, Mac or Windows. The recommended installation suggests the use of the **VScode** editor, because this exists in all three operating systems and it works in combination of their corresponding native C/C++ environments. This provides a universal toolchain that gives advantages when working from different types of machines. The installation of Neutrino, along this toolchain, is only sligthly different according to the underlying operating system. Please follow the instructions for the installation of Neutrino (as well as the VScode based toolchain thereby described) before continuing with the installation of the Examples.

# Linux, Mac and Windows 

## Installation:
The recommended method is by using the VScode toolchain described in the Neutrino repository. We assume Neutrino is going to be installed in a directory named *NeutrinoCodes* containing the following subdirectories:
- cl
- glad
- glfw
- gmsh
- libnu
- examples

where the corresponding software, according to the software requirements in this guide, has been already installed.

1. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and create a `libnu` directory using the command:\
`mkdir libnu`\
\
This will create the `libnu` directory.

2. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and clone the Neutrino project using the command:\
`git clone https://github.com/NeutrinoCodes/neutrino.git` \
\
This will create the `neutrino` directory.

3. Go to the `neutrino` directory and create a `.vscode` hidden directory:\
`mkdir .vscode`\
\
and create a new file `settings.json` in it, then fill it with the following information:\
`{`\
&nbsp;&nbsp;`"C_Cpp.default.configurationProvider": "vector-of-bool.cmake-tools",`\
&nbsp;&nbsp;`"cmake.configureArgs" : [   `\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGLAD_PATH=your_path_to_NeutrinoCodes/glad,`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGLFW_PATH=your_path_to_NeutrinoCodes/glfw",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGMSH_PATH=your_path_to_NeutrinoCodes/gmsh",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DNEUTRINO_PATH=your_path_to_NeutrinoCodes/libnu"`\
&nbsp;&nbsp;`]`\
`}`\
\
and save it.\
\
At this point, Neutrino is configured for your system. 

4. In VScode, go to the left bar and locate the **CMake** button (it comes after the installation of the CMake Tools extension for VScode) and push it: a CMake panel will open, push the **Configure All Projects** button on it.

5. In VScode, go to the bottom bar and locate the **Target** button: verify it has been selected to **[install]**.

6. In VScode, go to the bottom bar and locate the **Build** button: push it in order to build the Neutrino project.\
\
At this point the NeutrinoCodes directory should appear like this:
- glad
- glfw
- gmsh
- libnu
- neutrino

Congratulations, you have installed Neutrino on Linux!

# Mac 

## Hardware requirements:
- **OpenCL-OpenGL interoperability GPU mode**. Use the command line tool `clinfo` (see *Software requirements*) to check for the availability of this mode. On a terminal do:\
`clinfo`\
\
In the text output (it can be long!) there should be a section regarding your GPU similar to this one:\
...\
`Device Name                                     HD Graphics 5000`\
`Device Vendor                                   Intel`\
`Device Vendor ID                                0x1024500`\
`Device Version                                  OpenCL 1.2`\
`Driver Version                                  1.2(May 26 2020 20:53:48)`\
`Device OpenCL C Version                         OpenCL C 1.2`\
`Device Type                                     GPU`\
`Device Profile                                  FULL_PROFILE`\
...\
`Device Extensions                               cl_APPLE_SetMemObjectDestructor cl_APPLE_ContextLoggingFunctions cl_APPLE_clut cl_APPLE_query_kernel_names cl_APPLE_gl_sharing cl_khr_gl_event cl_khr_global_int32_base_atomics cl_khr_global_int32_extended_atomics cl_khr_local_int32_base_atomics cl_khr_local_int32_extended_atomics cl_khr_byte_addressable_store cl_khr_image2d_from_buffer cl_khr_gl_depth_images cl_khr_depth_images cl_khr_3d_image_writes`\
...\
\
and verify the presence of the `cl_APPLE_gl_sharing` extension.

## Software requirements:

- Clinfo (https://github.com/Oblomov/clinfo)
- OpenCL (runtime/loader + headers), coming along the OS-X installation.
- OpenGL (library + headers), coming along the OS-X installation.
- GIT (https://git-scm.com)
- GLAD (https://glad.dav1d.de/) *
- GLFW (https://www.glfw.org/) **
- GMSH (https://gmsh.info/)
- CLANG (https://clang.llvm.org/) ***
- CMake (https://cmake.org) ***
- GraphViz (https://graphviz.org/)
- Doxygen (http://www.doxygen.nl/)

Under Mac, it should be possible to install most of those packages via the **Homebrew** (https://brew.sh/) package manager.

\* The GLAD loader should be generated from its webpage using the following settings:
- Language = C/C++
- gl = Version 4.6 (or greater)
- Profile = Core

After having generated it, download the zip file containing the code and extract it in a custom directory (see *Installation*).

\** It might be possible that OS-X will not recognize GLFW as a valid software, throwing an error similar to this one:\
<p align="center">
<img src="./Pictures/Installation_mac/libglfw_mac_alert_1.png"/>
</p>
or this one:
<p align="center">
<img src="./Pictures/Installation_mac/libglfw_mac_alert_3.png"/>
</p>

In that case, you should enable it from the Mac OS-X *Security & Privacy* panel:\
<p align="center">
<img src="./Pictures/Installation_mac/libglfw_mac_alert_2.png"/>
</p>

\*** It is recommended to use the **VScode editor** and follow the instructions (https://code.visualstudio.com/docs/cpp/config-clang-macx) in order to install it and verify the installation of GCC, as well as the instructions (https://code.visualstudio.com/docs/cpp/cmake-linux, instructions for Linux but good also for Mac) to verify the installation of Cmake and to install the Cmake Tools extension for VSCode.

## Installation:
The recommended method is by using the VScode toolchain hereby described. We assume Neutrino is going to be installed in a directory named *NeutrinoCodes* containing the following subdirectories:
- glad
- glfw
- gmsh

where the corresponding software, according to the software requirements for Linux in this guide, has been already installed.

1. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and create a `libnu` directory using the command:\
`mkdir libnu`\
\
This will create the `libnu` directory.

2. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and clone the Neutrino project using the command:\
`git clone https://github.com/NeutrinoCodes/neutrino.git` \
\
This will create the `neutrino` directory.

3. Go to the `neutrino` directory and create a `.vscode` hidden directory:\
`mkdir .vscode`\
\
and create a new file `settings.json` in it, then fill it with the following information:\
`{`\
&nbsp;&nbsp;`"C_Cpp.default.configurationProvider": "vector-of-bool.cmake-tools",`\
&nbsp;&nbsp;`"cmake.configureArgs" : [   `\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGLAD_PATH=your_path_to_NeutrinoCodes/glad,`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGLFW_PATH=your_path_to_NeutrinoCodes/glfw",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGMSH_PATH=your_path_to_NeutrinoCodes/gmsh",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DNEUTRINO_PATH=your_path_to_NeutrinoCodes/libnu"`\
&nbsp;&nbsp;`]`\
`}`\
\
and save it.\
\
At this point, Neutrino is configured for your system. 

4. In VScode, go to the left bar and locate the **CMake** button (it comes after the installation of the CMake Tools extension for VScode) and push it: a CMake panel will open, push the **Configure All Projects** button on it.

5. In VScode, go to the bottom bar and locate the **Target** button: verify it has been selected to **[install]**.

6. In VScode, go to the bottom bar and locate the **Build** button: push it in order to build the Neutrino project.\
\
At this point the NeutrinoCodes directory should appear like this:
- glad
- glfw
- gmsh
- libnu
- neutrino

Congratulations, you have installed Neutrino on Mac!

# Windows

## Hardware requirements:
- **OpenCL-OpenGL interoperability GPU mode**. Use the command line tool `clinfo` (see *Software requirements*) to check for the availability of this mode. On a terminal do:\
`clinfo`\
\
In the text output (it can be long!) there should be a section regarding your GPU similar to this one:\
...\
`Name:                                          GeForce GTX 1060 6GB`\
`Vendor:                                        NVIDIA Corporation`\
`Driver version:                                451.67`\
`Profile:                                       FULL_PROFILE`\
`Version:                                       OpenCL 1.2 CUDA`\
`Extensions:                                    cl_khr_global_int32_base_atomics cl_khr_global_int32_extended_atomics cl_khr_local_int32_base_atomics cl_khr_local_int32_extended_atomics cl_khr_fp64 cl_khr_byte_addressable_store cl_khr_icd cl_khr_gl_sharing cl_nv_compiler_options cl_nv_device_attribute_query cl_nv_pragma_unroll cl_nv_d3d10_sharing cl_khr_d3d10_sharing cl_nv_d3d11_sharing cl_nv_copy_opts cl_nv_create_buffer cl_khr_int64_base_atomics cl_khr_int64_extended_atomics`\
...\
\
and verify the presence of the `cl_khr_gl_sharing` extension.

## Software requirements:

- Clinfo (https://github.com/Oblomov/clinfo)
- OpenCL (runtime/loader + headers),  comining along the installation of the graphics drivers
- OpenGL (library + headers), coming along the installation of the graphics drivers.
- GIT (https://git-scm.com)
- GLAD (https://glad.dav1d.de/) *
- GLFW (https://www.glfw.org/)
- GMSH (https://gmsh.info/)
- GCC (https://gcc.gnu.org) **
- CMake (https://cmake.org) **
- GraphViz (https://graphviz.org/)
- Doxygen (http://www.doxygen.nl/)

\* The GLAD loader should be generated from its webpage using the following settings:
- Language = C/C++
- gl = Version 4.6 (or greater)
- Profile = Core

After having generated it, download the zip file containing the code and extract it in a custom directory (see *Installation*).

\** It is recommended to use the **VScode editor** and follow the instructions (https://code.visualstudio.com/docs/cpp/config-linux) in order to install it and verify the installation of GCC, as well as the instructions (https://code.visualstudio.com/docs/cpp/cmake-linux) to verify the installation of Cmake and to install the Cmake Tools extension for VSCode.

## Installation:
The recommended method is by using the VScode toolchain hereby described. We assume Neutrino is going to be installed in a directory named *NeutrinoCodes* containing the following subdirectories:
- glad
- glfw
- gmsh

where the corresponding software, according to the software requirements for Linux in this guide, has been already installed.

**IMPORTANT NOTE FOR GMSH INSTALLATION ON WINDOWS**: GMSH is used in Neutrino as an API library. Under a Windows purely native environment (which is the case of Windows + the Visual Studio compiler) there is a limitation (see https://gitlab.onelab.info/gmsh/gmsh/-/issues/894) and because of this the GMSH API can used only as an external DLL. In order to install it on Windows, please download the GMSH's *Software Development Kit (SDK) for Windows* (64-bit or 32-bit, according to your operating system) and follow this procedure:
- after having downloaded the GMSH's SDK `.zip` file, extract it and copy the `gmsh` directory into the `NeutrinoCodes` directory.
- go to the `include` directory in the `gmsh` directory and rename the `gmsh.h` file `gmsh.h_original`.
- in the same directory, rename the `gmsh.h_cwrap` file to `gmsh.h`.
- go to the `lib` directory in the `gmsh` directory and copy che GMSH DLL file into `C.\Windows\System32`.

This should make the GMSH's API working on Windows.

Continuing with the installation of Neutrino:

1. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and create a `libnu` directory using the command:\
`mkdir libnu`\
\
This will create the `libnu` directory.

2. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and clone the Neutrino project using the command:\
`git clone https://github.com/NeutrinoCodes/neutrino.git` \
\
This will create the `neutrino` directory.

3. Go to the `neutrino` directory and create a `.vscode` hidden directory:\
`cd neutrino`\
`mkdir .vscode`\
\
and create a new file `settings.json` in it, then fill it with the following information:\
`{`\
&nbsp;&nbsp;`"C_Cpp.default.configurationProvider": "vector-of-bool.cmake-tools",`\
&nbsp;&nbsp;`"cmake.configureArgs" : [   `\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGLAD_PATH=your_path_to_NeutrinoCodes/glad,`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGLFW_PATH=your_path_to_NeutrinoCodes/glfw",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGMSH_PATH=your_path_to_NeutrinoCodes/gmsh",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DNEUTRINO_PATH=your_path_to_NeutrinoCodes/libnu"`\
&nbsp;&nbsp;`]`\
`}`\
\
and save it.\
\
At this point, Neutrino is configured for your system. 

4. In VScode, go to the left bar and locate the **CMake** button (it comes after the installation of the CMake Tools extension for VScode) and push it: a CMake panel will open, push the **Configure All Projects** button on it.

5. In VScode, go to the bottom bar and locate the **Target** button: verify it has been selected to **[install]**.

6. In VScode, go to the bottom bar and locate the **Build** button: push it in order to build the Neutrino project.\
\
At this point the NeutrinoCodes directory should appear like this:
- glad
- glfw
- gmsh
- libnu
- neutrino

Congratulations, you have installed Neutrino on Windows!

# Post installation (recommended)

## Uncrustify:
We all like tidy code! For this, we provide an **Uncrustify** (sources: https://github.com/uncrustify/uncrustify) configuration file specific for Neutrino. In order to use it, please first install Uncrustify according to your operating system (e.g. use the Linux's package manager, or Homebrew under Mac or use these binaries: https://sourceforge.net/projects/uncrustify/ under Windows), then install the VScode's *Uncrustify extension* (https://marketplace.visualstudio.com/items?itemName=LaurentTreguier.uncrustify).

According to your operating system, add the following lines to either the *global* or *project* **settings.json** file:

### Linux:
`"uncrustify.executablePath.linux": "your_path_to_uncrustify",`\
`"editor.defaultFormatter": "LaurentTreguier.uncrustify",`\
`"editor.formatOnSave": true`

### Mac:
`"uncrustify.executablePath.osx": "your_path_to_uncrustify",`\
`"editor.defaultFormatter": "LaurentTreguier.uncrustify",`\
`"editor.formatOnSave": true`

### Windows:
`"uncrustify.executablePath.windows": "your_path_to_uncrustify.exe",`\
`"editor.defaultFormatter": "LaurentTreguier.uncrustify",`\
`"editor.formatOnSave": true`\

To edit the *global* settings, on VScode go to the left bar: push the **Extensions** button and select the Uncrustify extension. Then go to **Manage --> Extension Settings** (gear-like icon) and edit the `settings.json` file by clicking one of the links in that section. This will set the Uncrustify code formatter globally in all your VScode projects (but still with per-project custom uncrustify configuration files).

To edit the *project* settings, open `settings.json` file in the `.vscode` you created for Neutrino (the hidden directory inside the `NeutrinoCodes` directory, see *Installation*) and put the same lines in it. This will set Uncrustify as code formatter (together with the configuration file we provide) only for the Neutrino project.

## Examples:
In order to test the installation of Neutrino and to start experimenting with it, please check the instructions present in the *Examples* repository: https://github.com/NeutrinoCodes/Examples.

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2020





Hardware requirements:
----
- OpenCL-compatible GPU with support for OpenCL-OpenGL.

It is better if the "interoperability" sharing modality exists. By using the tool  `clinfo`, under
Mac check for the `cl_APPLE_gl_sharing` extension, while under Linux or Windows check for the
`cl_khr_gl_sharing` extension.

Software requirements for Mac:
----
- OpenCL v1.2 (runtime/loader + headers) *
- OpenGL v4.6 (library + headers) *
- GLAD (https://glad.dav1d.de/) **
- GLFW v3.3 (https://www.glfw.org/)
- GCC v9.1 ***
- CMake v3.14.5 ***
- Make ***
- Git v2.21 ***
- GraphViz (https://graphviz.org/) ***
- Doxygen v1.8.15 (http://www.doxygen.nl/) ***
- Clinfo (https://github.com/Oblomov/clinfo) ***

\* They should be already present by default in the system.

\** The GLAD loader should be generated from its webpage using the following settings:
- Language = C/C++
- gl = Version 4.6
- Profile = Core

Download the zip file containing the code and extract it in a
custom directory, e.g. `/Users/yourname/glad`.

\*** If not present, they could be installed by using `brew` package manager (https://brew.sh/).

Software requirements for Linux:
----
- OpenCL v1.2 (runtime/loader + headers) *
- OpenGL v4.6 (library + headers) *
- GLAD (https://glad.dav1d.de/) **
- GLFW v3.3 (https://www.glfw.org/)
- GCC v9.1 *
- CMake v3.14.5 *
- Make *
- Git v2.21 *
- GraphViz (https://graphviz.org/) *
- Doxygen v1.8.15 (http://www.doxygen.nl/) *
- Clinfo (https://github.com/Oblomov/clinfo) *

\* If not present, they could be installed by using the system's package manager.

\** The GLAD loader should be generated from its webpage using the following settings:
- Language = C/C++
- gl = Version 4.6
- Profile = Core

Download the zip file containing the code and extract it in a
custom directory, e.g. `˜/glad`.

Software requirements for Windows:
----
- OpenCL v1.2 (runtime/loader + headers) *
- OpenGL v4.6 (library + headers) *
- GLAD (https://glad.dav1d.de/) **
- GLFW v3.3 (https://www.glfw.org/)
- Visual Studio 2019 (https://visualstudio.microsoft.com/) with "Desktop development
with C++ --> C++ CMake tools for Windows" workload.
- Git v2.21 (https://gitforwindows.org/)
- GraphViz (https://graphviz.org/)
- Doxygen v1.8.15 (http://www.doxygen.nl/)
- Clinfo (https://github.com/Oblomov/clinfo)

\* To be installed within the graphics card drivers coming from the manufacturer.

\** The GLAD loader should be generated from its webpage using the following settings:
- Language = C/C++
- gl = Version 4.6
- Profile = Core

Download the zip file containing the code and extract it in a
custom directory, e.g. `C:\Users\yourname\glad`.

Compilation
----

### Mac
1. From the command shell, navigate into your favourite directory and clone the Neutrino project
using the command `git clone https://github.com/NeutrinoCodes/examples.git`.
2. Cd into neutrino's project directory and edit the configuration script in the Code
subdirectory: `./configure_mac` by setting your paths. Provide the **absolute** path for the
following variables in the script:
- `DCMAKE_C_COMPILER`
- `DCMAKE_CXX_COMPILER`
- `DGLAD_PATH`
- `DGLFW_PATH`
- `DNEUTRINO_PATH`

During the installation of the Neutrino library you might already have set the following environment
variables in your `/Users/yourname/.bash_profile` in order to be used in the script:

e.g.

`export CC="/usr/local/bin/gcc-9"`
`export CCX="/usr/local/bin/g++-9"`
`export CPATH="/usr/local/include"`
`export LIBRARY_PATH="/usr/local/lib"`
`export NEUTRINOCODES_PATH="/users/yourname/NeutrinoCodes"`
`export NEUTRINO_PATH=$NEUTRINOCODES_PATH/libnu`
`export GLAD_PATH=$NEUTRINOCODES_PATH/glad`
`export GLFW_PATH=$NEUTRINOCODES_PATH/glfw`

P.S. after setting these variables, remember to exit and re-open the command shell or launch the
shell command `source /Users/yourname/.bash_profile` in order to have them refreshed by the system.
The first four variables are mandatory, because we are using gcc instead of Xcode.
In case you already exported these variables during the installation of the Neutrino library please
don't do it again now but only provide the asbolute paths for them as describe above for the
`./configure_mac` of **this** example (not to be confused with the corresponding file of the neutrino
library).

3. Then launch it by typing `./configure_mac` at the command prompt. The Cmake configuration files
will be generated.
4. Enter the `cmake` directory and type `make install` (use `make clean` to remove old build files
  if necessary).

### Linux
1. From the command shell, navigate into your favourite directory and clone neutrino project using
the command `git clone https://github.com/NeutrinoCodes/neutrino.git`.
2. Cd into neutrino's project directory and edit the configuration script in the Code
subdirectory: `./configure_linux` by setting your paths. Provide the **absolute** path for the
following variables in the script:
- `DGLAD_PATH`
- `DGLFW_PATH`
- `DNEUTRINO_PATH`

During the installation of the Neutrino library you might already have set the following environment
variables in your `/Users/yourname/.bash_profile` in order to be used in the script:

e.g.

`export NEUTRINOCODES_PATH="/users/yourname/NeutrinoCodes"`
`export NEUTRINO_PATH=$NEUTRINOCODES_PATH/libnu`
`export GLAD_PATH=$NEUTRINOCODES_PATH/glad`
`export GLFW_PATH=$NEUTRINOCODES_PATH/glfw`

P.S. after setting these variables, remember to exit and re-open the command shell or launch the
shell command `source /Users/yourname/.bash_profile` in order to have them refreshed by the system.
In case you already exported these variables during the installation of the Neutrino library please
don't do it again now but only provide the asbolute paths for them as describe above for the
`./configure_linux` of **this** example (not to be confused with the corresponding file of the
neutrino library).

3. Then launch it by typing `./configure_linux` at the command prompt. The Cmake configuration files
will be generated.
4. Enter the `cmake` directory and type `make install` (use `make clean` to remove old build files
  if necessary).

### Windows
1. Launch Command Prompt, navigate into your favorite directory and clone neutrino project using the command `git clone https://github.com/NeutrinoCodes/neutrino.git`.
2. Launch Visual Studio 2019 and select neutrino project folder.
3. Project -> CMake settings for neutrino -> Edit JSON; add the string `-DGLAD_PATH=C:/path/to/glad` `-DGLFW_PATH=C:/path/to/glfw` `-DCL_PATH=C:/path/to/opencl` to the parameter `cmakeCommandArgs` to specify the paths of GLAD, GLFW, and OpenCL headers (root directory). Also set the parameter `buildRoot` to `${projectDir}\\build\\windows`. Note: if you installed the NVIDIA GPU Computing Toolkit, `-DCL_PATH` will be something like `\"C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v9.1/\"` (notice the trailing and ending slashes, to be used if the path contains spaces).
4. Build -> Build All. The `.lib` file will be placed in the `libnu\lib` folder under the Neutrino project root directory.

### Final considerations
The `libnu` folder would be later used in order to build Neutrino applications. See the "Examples"
repository.

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2020
