include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
legD = 1;
tibia = 14; 
femur = 12;
a = [10,6]; //leg offsets


spec = [
    // legs
    move([-a.x,-a.y]), mb_connector([-4,0,0],[-6,0,tibia],legD, influence = 0.2),
    move([-a.x,a.y]), mb_connector([0,0,0],[0,0,tibia],legD, influence = 0.2),
    move([a.x,-a.y]), mb_connector([-2,0,0],[-3,0,tibia],legD, influence = 0.2),
    move([a.x,a.y]), mb_connector([0,0,0],[0,0,tibia],legD, influence = 0.2),

    move([-a.x,-a.y,tibia]), mb_connector([-6,0,0],[-2,0,femur],legD),
    move([-a.x,a.y,tibia]), mb_connector([0,0,0],[0,0,femur],legD),
    move([a.x,-a.y,tibia]), mb_connector([-3,0,0],[-1,0,femur],legD),
    move([a.x,a.y,tibia]), mb_connector([0,0,0],[0,0,femur],legD),

    up(tibia+femur+10), mb_cuboid([18,8,8]),
    up(tibia+femur+15)*left(10), mb_sphere(2),
    up(tibia+femur+35)*left(22)*yrot(-30)* yscale(0.75), mb_cyl(d1 = 8, d2 = 5, l = 38),
    up(75)*left(39)*yrot(45)* xscale(0.75), mb_cyl(d1 = 3, d2 = 8, l = 12),
    up(78)*left(35), mb_cuboid([3,3,3]),    


    /* */
];
bb = [[-45,-10,-35], [20,10,90]];
vol = (-bb[0].x+bb[1].x) * (-bb[0].y+bb[1].y) * (-bb[0].z+bb[1].z);
echo(vol);
auto = log(vol/5000);
echo(auto);
//#translate(bb[0]) cube(bb[1]-bb[0]);
metaballs(spec, 0.75, bb,show_stats = true);
