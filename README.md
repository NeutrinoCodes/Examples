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

# Linux

## Installation:
The recommended method is by using the VScode toolchain described in the Neutrino repository. We assume Neutrino is going to be installed in a directory named *NeutrinoCodes* containing the following subdirectories according to the already done installation of Neutrino:
- glad
- glfw
- gmsh
- libnu
- neutrino

1. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and clone the Neutrino project using the command:\
`git clone https://github.com/NeutrinoCodes/examples.git` \
\
This will create the `examples` directory.

2. Go to the `examples` directory and create a `.vscode` hidden directory:\
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

3. In VScode, go to the left bar and locate the **CMake** button (it comes after the installation of the CMake Tools extension for VScode) and push it: a CMake panel will open, push the **Configure All Projects** button on it.

4. In VScode, go to the bottom bar and locate the **Target** button: verify it has been selected to **[ALL_BUILD]** or select an individual example you want to build (e.g. [sinusoid]).

5. In VScode, go to the bottom bar and locate the **Build** button: push it in order to build the examples you selected.\
\
At this point the NeutrinoCodes directory should appear like this:
- glad
- glfw
- gmsh
- libnu
- neutrino
- examples

Congratulations, you have installed the Neutrino examples on Linux!

# Mac

## Installation:
The recommended method is by using the VScode toolchain described in the Neutrino repository. We assume Neutrino is going to be installed in a directory named *NeutrinoCodes* containing the following subdirectories according to the already done installation of Neutrino:
- glad
- glfw
- gmsh
- libnu
- neutrino

1. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and clone the Neutrino project using the command:\
`git clone https://github.com/NeutrinoCodes/examples.git` \
\
This will create the `examples` directory.

2. Go to the `examples` directory and create a `.vscode` hidden directory:\
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

3. In VScode, go to the left bar and locate the **CMake** button (it comes after the installation of the CMake Tools extension for VScode) and push it: a CMake panel will open, push the **Configure All Projects** button on it.

4. In VScode, go to the bottom bar and locate the **Target** button: verify it has been selected to **[ALL_BUILD]** or select an individual example you want to build (e.g. [sinusoid]).

5. In VScode, go to the bottom bar and locate the **Build** button: push it in order to build the examples you selected.\
\
At this point the NeutrinoCodes directory should appear like this:
- glad
- glfw
- gmsh
- libnu
- neutrino
- examples

Congratulations, you have installed the Neutrino examples on Mac!

# Windows

## Installation:
The recommended method is by using the VScode toolchain described in the Neutrino repository. We assume Neutrino is going to be installed in a directory named *NeutrinoCodes* containing the following subdirectories according to the already done installation of Neutrino:
- glad
- glfw
- gmsh
- libnu
- neutrino

1. From the command shell (either VScode's or system's), navigate into *NeutrinoCodes* and clone the Neutrino project using the command:\
`git clone https://github.com/NeutrinoCodes/examples.git` \
\
This will create the `examples` directory.

2. Go to the `neutrino` directory and create a `.vscode` hidden directory:\
`mkdir .vscode`\
\
and create a new file `settings.json` in it, then fill it with the following information:\
`{`\
&nbsp;&nbsp;`"C_Cpp.default.configurationProvider": "vector-of-bool.cmake-tools",`\
&nbsp;&nbsp;`"cmake.configureArgs" : [   `\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGLAD_PATH=your_path_to_NeutrinoCodes\\glad,`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGLFW_PATH=your_path_to_NeutrinoCodes\\glfw",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DGMSH_PATH=your_path_to_NeutrinoCodes\\gmsh",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DCL_PATH=your_path_to_OpenCL",`\
&nbsp;&nbsp;&nbsp;&nbsp;`"-DNEUTRINO_PATH=your_path_to_NeutrinoCodes\\libnu"`\
&nbsp;&nbsp;`]`\
`}`\
\
and save it.\
\
Notice all paths **must** be specificed with *double backslashes*, in order to correctly manage the possibility of space characters in the them.
Also notice that `your_path_to_OpenCL` might be something like this (it depends on your GPU's graphics drivers):\
`C:\\Program Files\\NVIDIA GPU Computing Toolkit\\CUDA\\v10.1`\
\
At this point, Neutrino is configured for your system.  

3. In VScode, go to the left bar and locate the **CMake** button (it comes after the installation of the CMake Tools extension for VScode) and push it: a CMake panel will open, push the **Configure All Projects** button on it.

4. In VScode, go to the bottom bar and locate the **Target** button: verify it has been selected to **[ALL_BUILD]** or select an individual example you want to build (e.g. [sinusoid]).

5. In VScode, go to the bottom bar and locate the **Build** button: push it in order to build the examples you selected.\
\
At this point the NeutrinoCodes directory should appear like this:
- glad
- glfw
- gmsh
- libnu
- neutrino
- examples

Congratulations, you have installed the Neutrino examples on Windows!

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

© Alessandro LUCANTONIO, Erik ZORZIN - 2018-2020