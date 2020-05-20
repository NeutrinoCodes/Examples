# Project documentation {#Project_documentation}

# 1. Chapter 1 {#Chapter_1}
Example of *italic*. Example of hyperlink to [something](https://example.com/).
Example of a GraphViz "graph" digram:

@dot
graph my_graph_diagram
{
  "host program\n(CPU)" -- "client kernel\n(GPU)" [label = " OpenCL"]
  "host program\n(CPU)" -- "OpenGL GUI" [label = " OpenGL"]
  "client kernel\n(GPU)" -- "OpenGL GUI" [label = " OpenCL/GL\ninteroperability"]
  {rank=same; "client kernel\n(GPU)", "OpenGL GUI"}
}
@enddot

Example of a GraphViz "digraph" digram:

@dot
digraph my_digraph_diagram
{
  "Neutrino" -> "User layer"
  "Neutrino" -> "Core layer" [style=dotted]
  "User layer" -> "program.cpp", "thekernel.cl"
  "Core layer" -> "main()", "\*.vert", "\*.frag" [style=dotted]
  "main()" -> "setup()", "loop()", "terminate()" [style=dotted]
  "program.cpp" -> "setup()"
  "program.cpp" -> "loop()"
  "program.cpp" -> "terminate()"
}
@enddot

# 2. Chapter 2 {#Chapter_2}
Unordered list:
- First item.
- Second item.

Unordered list with sub-levels:
- Level 1.
  - Level 2.
  - Level 2.
  - Level 2.
- Level 1.

# 3. Chapter 3 {#Chapter_3}
Example of code:
```
float a[N];
float b[N];
float c[N];

for (i = 0; i < N; i++)
{
  c[i] = a[i]*b[i];
}
```
