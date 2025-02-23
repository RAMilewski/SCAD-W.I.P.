include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
legD = 1;
tibia = 14; 
femur = 12;
head = [-35,0,78];
a = [12,6]; //leg offsets
voxel_size = 1.5;
bb = [[-45,-12,-5], [25,12,90]];

spec = [
    // legs
    move([-a.x,-a.y]), mb_connector([-4,0,0],[-6,0,tibia],legD, influence = 0.2),
    move([-a.x,a.y]),  mb_connector([0,0,0],[0,0,tibia],legD, influence = 0.2),
    move([a.x,-a.y]),  mb_connector([-2,0,0],[-3,0,tibia],legD, influence = 0.2),
    move([a.x,a.y]),   mb_connector([0,0,0],[0,0,tibia],legD, influence = 0.2),

    move([-a.x,-a.y,tibia]), mb_connector([-6,0,0],[-2,0,femur],legD),
    move([-a.x,a.y,tibia]),  mb_connector([0,0,0],[0,0,femur],legD),
    move([a.x,-a.y,tibia]),  mb_connector([-3,0,0],[-1,0,femur],legD),
    move([a.x,a.y,tibia]),  mb_connector([0,0,0],[0,0,femur],legD),

    // Hooves
    move([-a.x-5.5,-a.y]),  mb_cyl(d1 = 1.5, d2 = 0.2, h = 2, cutoff = 1),
    move([-a.x-1,a.y]), mb_cyl(d1 = 1.5, d2 = 0.2, h = 2, cutoff = 1),
    move([a.x-3.5,-a.y]), mb_cyl(d1 = 1.5, d2 = 0.2, h = 2, cutoff = 1),
    move([a.x-1,a.y]),  mb_cyl(d1 = 1.5, d2 = 0.2, h = 2, cutoff = 1),

    // Body
    up(tibia+femur+10) * yrot(10), mb_cuboid([18,8,8]),
    up(tibia+femur+15)*left(10), mb_sphere(2),
    up(tibia+femur+8)*right(13)*xrot(90), mb_disk(1,4),
    
    // Tail
    up(tibia+femur+8), mb_connector([18,0,0],[22,0,-16],0.5, cutoff = 1, influence = 0.2),
    
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
    
    // Ears
    move(head + [2,-8,4])* xrot(60) * scale([0.5,1,3]) , mb_sphere(d = 2, cutoff = 2),
    move(head + [2,8,4])* xrot(-60) * scale([0.5,1,3]) , mb_sphere(d = 2, cutoff = 2),
];

metaballs(spec, voxel_size, bb,show_stats = true);

    /* */