
include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
include <BOSL2/beziers.scad>

box_size = 85;
box = repeat(box_size,3);

//boundingbox = [-0.5*box, 0.5*box];
boundingbox = [[-40,-40,-20],[40,40,40]];

bez = flatten([
    bez_begin ([-25,25,25], -90, 35, p=90),
   
    bez_tang  ([25,0,0],  90, 25, p=90),
    bez_joint ([1,25,0], 95,-90, 40,85, p1=45, p2=90),
    bez_tang  ([15,-25,0], 0, 35, p=90), 
    bez_end   ([-25,25,25], -90, 25, p=-90)
]);

path = resample_path(bezpath_curve(bez, splinesteps = 64),100);
//color("skyblue") stroke(path, width = 0.2, closed = true);


centers = [[0,0,0], path[100 * $t] ];
charges = [10, 5];
type = MB_SPHERE;
isovalue = 1;
voxelsize = 1;
metaballs(voxelsize, boundingbox, isovalue=isovalue,
    ball_centers=centers, charge=charges, ball_type=type);

/*

move(path[$t*100]) color("blue") sphere(1, $fn = 32);
for (i = [0:99]) {
    move(path[i]) color("red") sphere(0.5, $fn = 32);
    echo(path[i]);
}

/*. */