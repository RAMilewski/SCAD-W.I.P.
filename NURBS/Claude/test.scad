include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
$ = [0,0,0];
   data = [[6.93543, 0.101467], [-7.00478, 0.502504],[-9.99294, 5.04672], [9.92071, 8.87502]];
   debug_nurbs_interp(data, 3, type="closed");

