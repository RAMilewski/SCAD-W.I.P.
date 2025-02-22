include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
legD = 1;
tibia = 14; 
femur = 12;
head = [-35,0,78];
a = [10,6]; //leg offsets
voxel_size = 0.5;
//bb = [[-45,-10,-35], [20,10,90]];
bb = [[-45,-10,60], [20,10,90]];

echo(head + [3,3,3]);
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
    // Neck
    up(tibia+femur+35)*left(22)*yrot(-30)* yscale(0.75), mb_cyl(d1 = 8, d2 = 5, l = 38),
    // Head
    move(head + [-4,0,-3])*yrot(45)*xscale(0.75), mb_cyl(d1 = 3, d2 = 8, l = 12),
    move(head), mb_cuboid([3,3,3]),    
    // Horns
    move(head), mb_connector([0,-2,5],[0,-2.5,8],0.3, cutoff = 1),
    move(head + [0,-2.5,8],), mb_sphere(0.5, cutoff = 1),
    move(head), mb_connector([0,2,5],[0,2.5,8],0.3, cutoff = 1),
    move(head + [0,2.5,8],), mb_sphere(0.5, cutoff = 1),

    /* */
];

metaballs(spec, voxel_size, bb,show_stats = true);
