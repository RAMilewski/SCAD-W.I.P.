include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 144;

core = 7.5;
cyldim = [90, 88, 4];
discs = [38,33,30];  // disc diameters
aspect = 28/38;
egg = [24,7,40]; //[dia,tang_cpd,height]
cup = [23,20,35]; //[od1,od2,h]


back_half() base();
base_cover();

/*
base() 
   position(TOP) disc(0)
        position(TOP) egg()
            position(TOP) disc(1)
                position(TOP) disc(2)
                    position(TOP) cup();

/* */

function cpd(dia) = dia * (4/3) * tan(180/8); //control point distance for a quarter-round to fit dia


module base(anchor = BOT) {
    bez = [[44,0],[20,10],[core,30],[core,40]];
    path = bezpath_curve(bezpath_close_to_axis(bez,"Y"));
    h = bez[3][1] + cyldim.z;
    attachable(anchor, h = h, d1 = cyldim[0], r2 = core) {
        down(h/2)
        diff() {
            cyl(d1 = cyldim[0], d2 = cyldim[1], h = cyldim.z, anchor=BOT) {
                position(TOP) rotate_sweep(path,360)
                down(cyldim.z) scale(0.85) {
                    tag("remove") position(BOT) cyl(d1 = cyldim[0], d2 = cyldim[1], h = cyldim.z, anchor=BOT)
                        tag("remove") position(TOP) rotate_sweep(path,360);    
                }
            }
        }
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
        down(height/2)
        rotate_sweep(path,360, anchor = anchor);
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
        down(egg.z/2) 
        rotate_sweep(path,360);
        children();
    }
}

module cup(anchor = BOT) {
    bezpath = flatten ([
        bez_begin([core,0], 85, cup.z/4),
        bez_tang([cup.x/2,cup.z/2.5], 90, cup.z/8),
        bez_joint([cup.y/2,cup.z], -86, 180, 10, 10),
        bez_joint([cup.y/2 - 1, cup.z], 0, -93, 10, 20),
        bez_end([0,cup.z/2], 0, cup.x/4),
    ]);

    path = bezpath_curve(bezpath_close_to_axis(bezpath,"Y"),splinesteps = 64);
    attachable(anchor, d = cup.x, h = cup.z) {
        down(cup.z/2)
        rotate_sweep(path,360);
        children();
    }
}

module base_cover(){
    scale(0.8) cyl(d1 = cyldim[0], d2 = cyldim[1], h = cyldim.z, anchor=BOT);
}
