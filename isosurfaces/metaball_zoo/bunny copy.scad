include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = false; // [true,false]

isovalue = 1;
voxel_size = 0.5;
bounding_box = [[-35,-35,0],[35,35,80]];

body = [
    up(20) * scale([1,1.2,2]), mb_sphere(10), 
    up(10), mb_sphere(5),   
    up(50) * scale([1.2,0.8,1]), mb_sphere(10, cutoff = 15),
    move([0,-11,50]), mb_cuboid(2),
    move([5,-10,54]), mb_sphere(0.5, negative = true),
    move([-5,-10,54]), mb_sphere(0.5, negative = true),
    move([0,15,6]), mb_sphere(2, cutoff = 5),
];

// eyes
xflip_copy() move([5,-8,54]) color("skyblue") sphere(2, $fn = 32);
//teeth
xflip_copy() move([1.1,-10,44]) color("white") cuboid([2,0.5,4], rounding = 0.15);


hind_leg = [ 
    move([-15,-5,3]) * scale([1.5,4,1.75]), mb_sphere(5),
    move([-15,10,3]), mb_sphere(3, negative = true),
];

front_leg = [ 
    move([-9,-4,30]) * zrot(30) * scale([1.5,5,1.75]), mb_sphere(3),
    move([-9,10,30]), mb_sphere(2, negative = true),
];

ear = [
    yrot(10) * move([0,0,65]) * scale([3,1,7]) , mb_sphere(2),
    yrot(10) * move([0,-5,65]) * scale([2,2,5]) , mb_sphere(2, cutoff = 3, influence =2, negative = true),
];


color("BurlyWood") {
    metaballs(funcs = body, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);
    xflip_copy() {
        metaballs(funcs = hind_leg, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);
        metaballs(funcs = front_leg, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);
        metaballs(funcs = ear, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);
    }
}



/*
up(20) left(50) ruler();
move([-15,5,3]) color("red") zcyl(10,0.2);
move([-15,10,3]) color("red") zcyl(10,0.2);

/* */