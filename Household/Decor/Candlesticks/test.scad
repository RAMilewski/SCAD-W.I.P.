include<BOSL2/std.scad>
include<BOSL2/threading.scad>

$fn = 72;
core = 7.5;

threaded_rod(d=INCH/4, height=22, pitch=INCH/20, 
                lead_in_shape = "smooth", bevel1 = -2, bevel2 = true, internal = false, $fa=1, $fs=1, anchor = BOT);

right(15)

threaded_rod(d=INCH/4, height=22, pitch=INCH/20, 
                lead_in_shape = "smooth", bevel1 = 2, bevel2 = true, internal = true, $slop = .1, $fa=1, $fs=1, anchor = BOT);

/* */