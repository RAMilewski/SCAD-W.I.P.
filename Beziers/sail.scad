include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
sail_width = 80;
sail_length = 0.7*sail_width;
center_z = 20;
edge_z = 8;

patch = [
    [[0, 0.5*sail_width, 0], [0.33*sail_length,  0.36*sail_width, edge_z], 
            [0.67*sail_length, 0.15*sail_width, edge_z], [sail_length, 0, 0]],
    [[0, 0, 0], [0.33*sail_length, 0, center_z], 
            [0.67*sail_length, 0, center_z-5], [sail_length, 0, 0]],
    [[0, -0.5*sail_width, 0], [0.33*sail_length, -0.36*sail_width, edge_z], 
            [0.67*sail_length, -0.15*sail_width, edge_z], [sail_length, 0, 0]]
];
//debug_bezier_patches(patches=[patch], size=1, showcps=false);

 vnf = bezier_vnf([ patch, up(1, patch), ]); difference() { 
    hull() vnf_polyhedron(vnf); translate([0, 0, -0.75]) scale([1.01, 1.01, 1.00]) hull() vnf_polyhedron(vnf); }

