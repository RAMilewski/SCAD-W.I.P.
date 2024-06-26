// Escher's Solid - (Stellated Rhombic Dodecahedron)

include <BOSL2/std.scad>
include <BOSL2/polyhedra.scad>

// Requres the BOSL2 library: https://github.com/BelfrySCAD/BOSL2#installation
// Documentation at: https://github.com/BelfrySCAD/BOSL2/wiki

size = 20;

regular_polyhedron("dodecahedron", d = size, facedown = false);

