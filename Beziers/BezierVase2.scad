include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

side_bez = [[20,0], [40,40], [-10,70], [20,100]];
side = bezpath_curve(side_bez, splinesteps = 35);
r_base = side_bez[0].x;
h = last(side).y;
steps = len(side)-1;
step = h/steps;
wall = 2;

r = 30;  // radius of the circle
n = 4;   //bezier segments to complete circle
d1 = r * (4/3) * tan(180/(2*n)); //control point distance
echo(d1, d);

layer_bez = flatten([
    bez_begin ([-r,0,0],  90, d, ),
    bez_tang  ([0,r,2],    0, d, ),
    bez_tang  ([r,0,2],  -90, d, ),
    bez_tang  ([0,-r,2], 180, d, ),    
    bez_end   ([-r,0,0], -90, d, )
]);

layer = bezpath_curve(layer_bez);


function layer_xy_scale(z) =
    let (sample_z = side_bez[0].y + z * step) // the sampling height
    let (u = bezier_line_intersection(side_bez, [[0, sample_z],[1, sample_z]]))
    flatten(bezier_points(side_bez,u)).x / r_base;

function layer_z_scale(z) = min(z^2/steps,1);  

outside = [for(i=[0:steps]) scale([layer_xy_scale(i),layer_xy_scale(i),layer_z_scale(i)],up(i*step, layer))];
inside = [for (curve = outside) hstack(offset(path2d(curve), delta = -2, same_length = true), column(curve,2))];
base = path3d(path2d(outside[0]));  //flatten the base but keep as a 3d path
floor = up(wall, path3d(offset(path2d(outside[0]), -wall)));

skin([ base, each outside, each reverse(inside), floor], slices=0, refine=1, method="fast_distance");

