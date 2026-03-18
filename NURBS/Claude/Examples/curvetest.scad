include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<../nurbs_interp.scad>
include<data.scad>

$vpt = [0,0,0];
$vpr = [0,0,0];

method="centripetal";   // [length,centripetal,dynamic,foley,lockyer]


debug_nurbs_interp(data5,3,method=method, width = .2, show_ctrl = false, splinesteps=32 );