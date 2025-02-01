
include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <new_code.scad>


bez = flatten([
    bez_begin ([-25,25,25], -90, 35, p=90),
   
    bez_tang  ([25,0,0],  90, 25, p=90),
    bez_joint ([1,25,0], 95,-90, 40,85, p1=45, p2=90),
    bez_tang  ([15,-25,-8], 0, 35, p=90), 
    bez_end   ([-25,25,25], -90, 25, p=-90)
]);

path = resample_path(bezpath_curve(bez),100);
//color("skyblue") stroke(path, width = 0.2, closed = true);

bounding_box = [[-40,-40,-20],[40,40,40]];
funcs = [
    move([0,0,0]),      mb_sphere(10),
    move(path[100*$t]), mb_sphere(5),
];
isovalue = 1;
voxel_size = 1;

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size);

/*
move(path[$t*100]) color("blue") sphere(1, $fn = 32);
for (i = [0:99]) {
    move(path[i]) color("red") sphere(0.5, $fn = 32);
    echo(path[i]);
}

/* */