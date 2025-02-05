
include <BOSL2/std.scad>
include <new_code.scad>

stats = false; // [true,false]


bounding_box = [[-60,-50,-7],[35,50,21]];
funcs = [
    move([-20,0,0]), mb_ellipsoid([25,4,4]),            // fuselage
    move([30,0,5]),  mb_ellipsoid([4,0.5,8]),           // vertical stabilizer
    move([30,0,0]),  mb_ellipsoid([4,15,0.5]),          // horizontal stabilizer
    move([-20,0,0]), mb_ellipsoid([5,45,0.5])           // wing
];  
isovalue = 1;
voxel_size = 0.9;   // [0.9:0.1:1.5]

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);


/* */