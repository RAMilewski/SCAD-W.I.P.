include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = false; // [true,false]

isovalue = 1;
voxel_size = 0.5;
bounding_box = [[-25,-25,0],[25,25,30]];

hind_leg = [ 
    move([-15,-5,3]) * scale([1.5,4,1.75]), mb_sphere(5),
    move([-15,10,3]), mb_sphere(3, negative = true),
];

ear = [
    yrot(10) * move([0,0,65]) * scale([3,1,7]) , mb_sphere(2),
    yrot(10) * move([0,-5,65]) * scale([2,2,5]) , mb_sphere(2, cutoff = 3, influence =2, negative = true),
    

];


color("BurlyWood") {
   // metaballs(funcs = body, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);
    xflip_copy() {
        metaballs(funcs = hind_leg, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);
     //   metaballs(funcs = front_leg, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);
     //  top_half() metaballs(funcs = ear, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);
    }
}



/*
up(20) left(50) ruler();
move([-15,5,3]) color("red") zcyl(10,0.2);
move([-15,10,3]) color("red") zcyl(10,0.2);

/* */