include<BOSL2/std.scad>
include<BOSL2/screws.scad>
include<BOSL2/threading.scad>

d1 = 6;  //Cable Diameter
d2 = d1*2;
d3 = d1*3;
$fn = 72;

//back_half()
cap(); right(d3 * 3/2) base();



module base() {
    diff() {
        cyl(d = d3, h = d1 * 3/2, texture = "wave_ribs", tex_reps = [50,1], tex_depth = -.35, anchor = BOT){
            tag("remove") position(BOT) up(d1/2) {
                cuboid([d1,d3+1,d3], rounding = d1/2, edges = "Y", anchor = BOT);
                cyl(d = d3/2, h = d2, anchor = BOT);
                screw_hole("#6", l=24, head = "flat", counterbore = 0.25, anchor = TOP);
            }
            position(TOP) threaded_rod(d = d3 * 3/4, h = d1 * 4/5, pitch = 2, starts = 2, blunt_start2 = true, anchor = BOT );
        }
    }
}

module cap() {
    diff() {
        cyl(d = d3, h = d1 * 4/3, texture = "wave_ribs", tex_reps = [50,1], tex_depth = -.35, anchor = BOT) {
            tag("remove") position(TOP) 
                threaded_rod(d = d3 * 3/4, h = d1, pitch = 2, starts = 2, blunt_start2 = true, internal = true, $slop = 0.1, anchor = TOP );
            tag("keep") position(BOT) up (d1/3) cyl(d = d3/2.2, h = d1 * 4/3 , rounding2 = 3, anchor = BOT);
        }
    }
}