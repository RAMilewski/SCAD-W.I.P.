include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = false; // [true,false]

bounding_box = [[-60,-50,-5],[35,50,21]];
funcs = [
    move([-20,0,0]) * scale([25,4,4]),   mb_sphere(1),     
    move([30,0,5])  * scale([4,0.5,8]),  mb_sphere(1),      
    move([30,0,0])  * scale([4,15,0.5]), mb_sphere(1),      
    move([-15,0,0]) * scale([6,45,0.5]), mb_sphere(1),      
];  
isovalue = 1;
voxel_size = 1;

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);


/* */