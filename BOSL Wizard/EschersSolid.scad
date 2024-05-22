// Escher's Solid - (Stellated Rhombic Dodecahedron)

include <BOSL2/std.scad>
include <BOSL2/polyhedra.scad>

// Requres the BOSL2 library: https://github.com/BelfrySCAD/BOSL2#installation
// Documentation at: https://github.com/BelfrySCAD/BOSL2/wiki

size = 60;

regular_polyhedron("rhombic dodecahedron", d = size, stellate = 0.8165, facedown = false);

