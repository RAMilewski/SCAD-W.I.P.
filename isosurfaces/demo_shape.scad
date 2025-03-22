include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = false; // [true,false]

bb = [[-50,-10,-5],[35,10,21]];

vol = (-bb[0].x+bb[1].x) * (-bb[0].y+bb[1].y) * (-bb[0].z+bb[1].z);
echo(vol);
auto = log(vol/5000);
echo(auto);

spec = [
    move([-20,0,0]) * scale([25,4,4]),   mb_sphere(1),     
    //move([30,0,5])  * scale([4,0.5,8]),  mb_sphere(1),      
    //move([30,0,0])  * scale([4,15,0.5]), mb_sphere(1),      
    //move([-15,0,0]) * scale([6,45,0.5]), mb_sphere(1),      
]; 

metaballs(spec, bb, show_stats = stats);


/* */