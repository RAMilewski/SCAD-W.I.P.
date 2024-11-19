include<BOSL2/std.scad>
include<BOSL2/threading.scad>

$fn = 72;
core = 7.5;

threaded_rod(d=7.5, height=20, pitch=1.5, 
                lead_in_shape = "smooth", bevel1 = -2, bevel2 = true, internal = false, $fa=1, $fs=1, anchor = BOT);

right(15)

threaded_rod(d=7.5, height=22, pitch=1.5, 
                lead_in_shape = "smooth", bevel1 = 2, bevel2 = true, internal = true, $slop = .13, $fa=1, $fs=1, anchor = BOT);

right(35)

test2();



/* */

module test2() {
    diff() {
        cyl(h = 6, d = 20, $fn = 6)
            tag("remove") position(BOT) threaded_rod(d=7.5, height=20, pitch=1.5, 
                lead_in_shape = "smooth", bevel2 = -3, bevel1 = true, internal = true, $slop = .13, $fn = 72, $fa=1, $fs=1, anchor = BOT);  
    }
}