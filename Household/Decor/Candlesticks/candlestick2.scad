include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 144;

core = 7.5;
discs = [38,33,30];  
aspect = 28/38;
egg = [24,7,40]; //[dia,tang_cpd,height]
cup = [23,22,35]; //[d1,d2,h]



base() 
   position(TOP) up(10) disc(0);  /*
        position(TOP) down(6) egg()
            position(TOP) up(7) disc(1)
                position(TOP) disc(2)
                    position(TOP) down(7) cup();

/* */

function cpd(dia) = dia * (4/3) * tan(180/8); //control point distance for a quarter-round to fit dia


module base(anchor = BOT) {
    bez = [[44,0],[20,10],[core,30],[core,40]];
    path = bezpath_curve(bezpath_close_to_axis(bez,"Y"));
    cyl(d1 = 90, d2 = 88, h = 4, anchor = anchor)
    attachable(anchor, h = bez[1][1], r = bez[0][0]) {
        position(TOP) rotate_sweep(path, 360, anchor = anchor);
        children();
    }
}


module disc(idx, anchor = BOT) {
    radius = discs[idx]/2;
    height = discs[idx] * aspect;
    bezpath = flatten([
            bez_begin([core,0], 90, cpd(height*.7)),
            bez_tang([radius,height/2], 90, height/8),
            bez_end([core,height], -90, cpd(height))
    ]);
    path = bezpath_curve(bezpath_close_to_axis(bezpath,"Y"),splinesteps = 64);
    attachable(anchor, h = height, r = radius) {
        rotate_sweep(path,360);
        children();
    }
}

module egg(anchor = BOT) {

    bezpath = flatten([
            bez_begin([core,0], 85, egg.z/4),
            bez_tang([egg.x/2,egg.z/2], 90, egg.y),
            bez_end([core,egg.z], -85, egg.z/4)
    ]);

    path = bezpath_curve(bezpath_close_to_axis(bezpath,"Y"),splinesteps = 64);
    attachable(anchor, d = egg.x, h = egg.z) {
        rotate_sweep(path,360);
        children();
    }
}

module cup(anchor = BOT) {
    bezpath = flatten ([
        bez_begin([core,0], 85, cup.z/4),
        bez_tang([cup.x/2,cup.z/2.5], 90, cup.z/8),
        bez_joint([cup.x/2,cup.z], 90, 180, 10, 10),
        bez_joint([cup.x/2 - 2, cup.z], 0, -90, 10, 20),
        bez_end([0,cup.z/2], 0, cup.x/4),
        
    ]);
    //debug_bezier(bezpath, width = 0.2);
    path = bezpath_curve(bezpath_close_to_axis(bezpath,"Y"),splinesteps = 64);
    attachable(anchor, d = cup.x, h = cup.z) {
        rotate_sweep(path,360);
        children();
    }
}