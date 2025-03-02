include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = false; // [true,false]

bb = [[-60,-50,-5],[35,50,21]];


spec = [
    move([-20,0,0]) * scale([25,4,4]),   mb_sphere(1),          // fuselage
    move([30,0,5])  * scale([4,0.5,8]),  mb_sphere(1),          // vertical stabilizer
    move([30,0,0])  * scale([4,15,0.5]), mb_sphere(1),          // horizontal stabilizer
    move([-15,0,0]) * scale([6,45,0.5]), mb_sphere(1),          // wing
    move([-20,0,4]) * scale([3,1.3,1.5]), mb_sphere(1, cutoff = 4), // cockpit
];  


metaballs(spec, bb, 1, show_stats = stats);


/* */