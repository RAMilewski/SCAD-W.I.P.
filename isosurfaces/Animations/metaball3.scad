
include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
include <BOSL2/beziers.scad>

box_size = 85;
box = repeat(box_size,3);
framecount = 200;

//bounding_box = [-0.5*box, 0.5*box];
bb = [[-50,-50,-30],[50,50,50]];

bez = flatten([
    bez_begin ([-35,35,25], -90, 35, p=90),
    bez_tang  ([35,0,0],  90, 25, p=90),
    bez_joint ([1,35,0], 95,-90, 40,85, p1=45, p2=90),
    bez_tang  ([15,-35,0], 0, 35, p=90), 
    bez_end   ([-35,35,25], -90, 25, p=-90)
]);

path = resample_path(bezpath_curve(bez, splinesteps = 64),framecount);
//color("skyblue") stroke(path, width = 0.2, closed = true);


echo(path[framecount * $t]);

funcs =[ 
    IDENT, mb_sphere(10),
    move(path[framecount * $t]), mb_sphere(5),
    ];
isovalue = 1;
voxelsize = 1;
metaballs(funcs, bb, voxelsize, show_stats = true);

/*. */