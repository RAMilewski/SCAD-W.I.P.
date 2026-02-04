include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 144;

dia = 6 * INCH;
len1 = 5 * INCH;     //smooth length
len2 = 1/2 * INCH;   //flange length
fwidth = 1/2 * INCH; //flange width
tlen = 2 * INCH;     //threaded length
clen = 1 * INCH;     //collar length
cdia = 7 * INCH;     //collar OD
csides = $fn;        //collar sides 
wall = 4;

part = "tube"; //[tube, collar]

if (part == "tube") window_tube();
if (part == "collar") collar();

module window_tube() {
    tube(od = dia, l = len1, wall = wall, anchor = BOT) {
        position(BOT) torus(d_min = wall, d_maj = dia, anchor = BOT);
        diff()
            attach(TOP,BOT) {
                tube(id = dia - 2 * wall, od1 = dia, od2 = dia + fwidth * 2, l = len2, anchor = BOT);
                acme_threaded_rod(d = dia, l = tlen, pitch = 5, starts = 4, blunt_start = true, anchor = BOT);
                tag("remove") cyl(d = dia - 2 * wall, l = tlen + .1, anchor = BOT);
            }
    }
}

module collar() {
    diff() {
        cyl (d = cdia, l = clen, circum = true, $fn = csides, anchor = BOT);
        tag("remove") acme_threaded_rod(d = dia, l = clen, pitch = 5, starts = 4, 
            blunt_start = true, internal = true, $slop =0.2, anchor = BOT);
    }
}