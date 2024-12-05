include<BOSL2/std.scad>
include<BOSL2/beziers.scad>
include <BOSL2/threading.scad>

part = "ballast";  // ["ballast", "bottom", "top", test, test2]

if (part == "ballast") ballast_plate();
if (part == "bottom")  bottom(); 
if (part == "top")     zrot(175) top();  //zrot to align seam with bottom
if (part == "test") {
        ghost_this() bottom() 
            ballast_plate();
    //move([-INCH,0,50]) yrot(90) xrot(90) ruler();
}
if (part == "test2") { 
    
}


/* [Hidden] */

$fn = 144;

core = 7.5;
cyldim = [90, 88, 6];
basewall = 4;
discs = [38,33,30];  // disc diameters
aspect = 28/38;
egg = [24,7,40]; //[dia,tang_cpd,height]
cup = [30,26,35]; //[od1,od2,h]


function cpd(dia) = dia * (4/3) * tan(180/8); //control point distance for a quarter-round to fit dia


module base(anchor = BOT) {
    bez = [[44,0],[20,10],[core,30],[core,40]];
    bez2 = 0.9 * bez;
    path = bezpath_curve(bezpath_close_to_axis(bez,"Y"));
    path2 = bezpath_curve(bezpath_close_to_axis(bez2,"Y"));
    h = bez[3][1] + cyldim.z;
    attachable(anchor, h = h, d1 = cyldim[0], r2 = core) {
        down(h/2)
        diff() {
            tube(od1 = cyldim[0], od2 = cyldim[1], wall = basewall, h = cyldim.z, anchor=BOT) {
                position(TOP) rotate_sweep(path,360);
                tag("remove") position(TOP) rotate_sweep(path2,360)   
                tag("remove") position(TOP) cyl(r1 = core, r2 = core * .7, h = 10);

                
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
    attachable(anchor = anchor, h = height, r = radius) {
        down(height/2)
        diff() {
            rotate_sweep(path,360);
            tag("remove") threaded_rod(d=7, height=20, pitch=1.5, 
                lead_in_shape = "smooth", bevel1 = 2, internal = true, $slop = .15, $fa=1, $fs=1, anchor = BOT);  
            }
        children();
    }
}

module egg(anchor = BOT) {

   { bezpath = flatten([
            bez_begin([core,0], 85, egg.z/4),
            bez_tang([egg.x/2,egg.z/2], 90, egg.y),
            bez_end([core,egg.z], -85, egg.z/4)
    ]);}

    path = bezpath_curve(bezpath_close_to_axis(bezpath,"Y"),splinesteps = 64);
    attachable(anchor, d = egg.x, h = egg.z) {
        down(egg.z/2) 
        rotate_sweep(path,360);
        children();
    }
}

module cup(anchor = BOT) {
   bezpath = flatten ([
        bez_begin([core,0], 85, cup.z/3),
        bez_tang([cup.x/2,cup.z/2.5], 90, cup.z/8),
        bez_joint([cup.y/2,cup.z], -86, 180, 10, 10),
        bez_joint([cup.y/2 - 2, cup.z], 0, -93, 10, 20),
        bez_end([0,cup.z/2], 0, cup.x/2.5),
    ]);

    path = bezpath_curve(bezpath_close_to_axis(bezpath,"Y"),splinesteps = 64);
    attachable(anchor, d = cup.x, h = cup.z) {
        down(cup.z/2)
        rotate_sweep(path,360);
        children();
    }
}

module ballast_plate() {
    diff() {
        d1 =  cyldim[0] - basewall*2 -1;
        d2 = (cyldim[0]-cyldim[1])/2 + cyldim[1] - basewall*2 - 1;
        cyl(d1 = d1, d2 = d2, h = cyldim.z/2, anchor=BOT) {
            tag("remove") position(BOT) cuboid([30,5,cyldim.z/3], rounding = 1.5, edges = TOP, anchor = BOT);
            tag("keep") position(TOP) threaded_rod(d=7, height=50, pitch=1.5, 
                lead_in_shape = "smooth", bevel1 = -2, bevel2 = true, $fa=1, $fs=1, anchor = BOT);
        }
    }
}

module bottom() {
    base()
        position(TOP) down(1) ghost() disc(0)   
            position(TOP) threaded_rod(d=10, height=10, pitch=2.5, 
                lead_in_shape = "smooth", bevel1 = -1, bevel2 = true, $fa=1, $fs=1, anchor = BOT);
}

module top() {
    diff() {
        egg() {
        position(BOT) tag("remove") threaded_rod(d=10, height=15, pitch=2.5, 
                lead_in_shape = "smooth", bevel1 = 1, internal = true, $slop = .13, $fa=1, $fs=1, anchor = BOT);
        position(TOP) disc(1)
                position(TOP) disc(2)
                    position(TOP) cup();
        }
    }
}

module test2() {
    base();
}