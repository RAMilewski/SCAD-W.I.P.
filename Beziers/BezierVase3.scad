include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

//Side Bézier Path
side_bez = [[20,0], [40,40], [-10,70], [20,100]];
side = bezpath_curve(side_bez, splinesteps = 32);
h = last(side).y;
steps = len(side)-1;
step = h/steps;
wall = 2;

//Layer Bézier Path
size = side_bez[0].x; // size of the base
d = size * 0.8;       // intermediate control point distance
theta = 65;           // adjusts layer "wavyness".
bz = 5*cos(theta);    // offset to raise layer curve minima above z = 0;
                 
layer_bez = flatten([
    bez_begin ([-size,0,bz],  90, d, p=theta),
    bez_tang  ([0, size,bz],   0, d, p=theta),
    bez_tang  ([size, 0,bz], -90, d, p=theta),
    bez_tang  ([0,-size,bz], 180, d, p=theta),    
    bez_end   ([-size,0,bz], -90, d, p=180 - theta)
]);

layer = bezpath_curve(layer_bez);

function layer_xy_scale(z) =
    let (sample_z = side_bez[0].y + z * step) // the sampling height
    let (u = bezier_line_intersection(side_bez, [[0, sample_z],[1, sample_z]]))
    flatten(bezier_points(side_bez,u)).x / side_bez[0].x;

outside =[for(i=[0:steps]) scale([layer_xy_scale(i),layer_xy_scale(i),1],up(i*step, layer))];
inside = [for (curve = outside) hstack(offset(path2d(curve), delta = -2, same_length = true), column(curve,2))];

base = path3d(path2d(outside[0]));  //flatten the base but keep as a 3d path
floor = up(wall, path3d(offset(path2d(outside[0]), -wall)));

skin([ base, each outside, each reverse(inside), floor ], slices=0, refine=1, method="fast_distance");
