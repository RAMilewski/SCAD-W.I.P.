include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

legD = 1;
tibia = 14; 
femur = 12;
head = [-35,0,78];  //head position
stance = [12,6];    //leg position offsets
vsize = 0.85;
//bbox =  [[-45.5, -11.5, 0], [23, 11.5, 87.55]];
bbox =  [[-45.5, -11.5, 60], [23, 11.5, 87.55]];

spec = [
    // Legs
    move([-stance.x,-stance.y]), mb_connector([-4,0,0],[-6,0,tibia],legD, influence = 0.2),
    move([-stance.x,stance.y]),  mb_connector([0,0,0],[0,0,tibia],legD, influence = 0.2),
    move([stance.x,-stance.y]),  mb_connector([-2,0,0],[-3,0,tibia],legD, influence = 0.2),
    move([stance.x,stance.y]),   mb_connector([0,0,0],[0,0,tibia],legD, influence = 0.2),

    move([-stance.x,-stance.y,tibia]), mb_connector([-6,0,0],[-2,0,femur],legD),
    move([-stance.x,stance.y,tibia]),  mb_connector([0,0,0],[0,0,femur],legD),
    move([stance.x,-stance.y,tibia]),  mb_connector([-3,0,0],[-1,0,femur],legD),
    move([stance.x,stance.y,tibia]),   mb_connector([0,0,0],[0,0,femur],legD),

    // Hooves
    move([-stance.x-6,-stance.y,1]),    mb_capsule(d= 2, h = 3, cutoff = 2),
    move([-stance.x-1,stance.y,1]),     mb_capsule(d= 2, h = 3, cutoff = 2),
    move([stance.x-3.5,-stance.y,1]),   mb_capsule(d= 2, h = 3, cutoff = 2),
    move([stance.x-1,stance.y,1]),      mb_capsule(d= 2, h = 3, cutoff = 2),

    // Body
    up(tibia+femur+10) * yrot(10),        mb_cuboid([16,7,7]),
    up(tibia+femur+15)*left(10),          mb_sphere(2),
    up(tibia+femur+8)*right(13)*xrot(90), mb_disk(1,4),
    
    // Tail
    up(tibia+femur+8), mb_connector([18,0,0],[22,0,-16], 0.4, cutoff = 1),
    
    // Neck
    up(tibia+femur+35)*left(22)*yrot(-30)* yscale(0.75), mb_cyl(d1 = 5, d2 = 3, l = 38),
    
    // Head
    move(head + [-4,0,-3])*yrot(45)*xscale(0.75), mb_cyl(d1 = 1.5, d2 = 4, l = 12, rounding=0),
    move(head), mb_cuboid(2),    
    
    // Horns
    move(head), mb_connector([0,-2,5],[0,-2.5,8],0.15, cutoff = 1.5),
    move(head + [0,-2.5,8]), mb_sphere(0.5, cutoff = 1),
    move(head), mb_connector([0,2,5],[0,2.5,8],0.15, cutoff = 1.5),
    move(head + [0,2.5,8]), mb_sphere(0.5, cutoff = 1),
    
    // Ears
    move(head + [2,-8,4])* xrot(60) * scale([0.5,1,3]) , mb_sphere(d = 2, cutoff = 2),
    move(head + [2,8,4])* xrot(-60) * scale([0.5,1,3]) , mb_sphere(d = 2, cutoff = 2),
];

metaballs(spec, bbox, voxel_size=vsize, debug = true, show_stats = true);