include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <shapeset.scad>
include <TEX/texture.data>
$fn = 64;
shape = 4;
bez = shapeset[shape];

offset = [2,0];
floor = 2;
is2d = false;
 
smooth(0,0.25,is2d);
textured(0.25,0.75,is2d);
smooth(0.75,1,is2d);
u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);
cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, anchor = BOT);


module smooth(umin,umax,2d) { 
    path = bezier_points(bez, [umin:0.01:umax]);
    if(is2d) stroke(offset_path(path,offset));
    if (!is2d) rotate_sweep(offset_path(path,offset),360);
}

module textured(umin,umax,2d) {
    path = bezier_points(bez, [umin:0.01:umax]);
    if(is2d) stroke(offset_path(path,offset));
    if(!is2d) {
        path2 = offset_path(path,offset);
        rotate_sweep(path2, 360, texture = texture, tex_reps = [20,1], tex_depth = 0.75);
    }
}

function offset_path(path,offset) =
    let (
        backpath = reverse( [for (i = [0:len(path)-1]) path[i]+ offset]),
        pathend = len(path)-1
    ) concat (
        list_head(path),
        lerpn(path[pathend], backpath[0], 3, false),
        list_head(backpath),
        lerpn(backpath[pathend], path[0], 4)
    );


