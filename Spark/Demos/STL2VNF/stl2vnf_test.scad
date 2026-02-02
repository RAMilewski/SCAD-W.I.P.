
include <BOSL2/std.scad>
vnf_data = include <vnf.data>; 
// vnf_list now contains a list of VNF (OpenSCAD polyhedron) structures
echo(vnf_data);
vnf_polyhedron(vnf_data);