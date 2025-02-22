include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = false; // [true,false]

isovalue = 1;
voxel_size = 1;
b_box = [[-25,-25,0],[25,25,81]];

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
    metaballs(body, voxel_size, b_box, isovalue, show_stats = true);
    xflip_copy() {
        metaballs(hind_leg, voxel_size, b_box, isovalue, show_stats = true);
        metaballs(front_leg, voxel_size, b_box, isovalue, show_stats = true);
        metaballs(ear, voxel_size, b_box, isovalue, show_stats = true);
    }
}



/*
up(20) left(50) ruler();
move([-15,5,3]) color("red") zcyl(10,0.2);
move([-15,10,3]) color("red") zcyl(10,0.2);

/* */