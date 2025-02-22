include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = false; // [true,false]

bb = [[-60,-50,-5],[35,50,21]];

vol = (-bb[0].x+bb[1].x) * (-bb[0].y+bb[1].y) * (-bb[0].z+bb[1].z);
echo(vol);
auto = log(vol/5000);
echo(auto);


spec = [
    move([-20,0,0]) * scale([25,4,4]),   mb_sphere(1),      // fuselage
    move([30,0,5])  * scale([4,0.5,8]),  mb_sphere(1),      // vertical stabilizer
    move([30,0,0])  * scale([4,15,0.5]), mb_sphere(1),      // horizontal stabilizer
    move([-20,0,0]) * scale([6,45,0.5]), mb_sphere(1),      // wing
];  


metaballs(spec, 1, bb, show_stats = stats);


/* */