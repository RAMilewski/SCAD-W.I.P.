include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 144;

dia = 6 * INCH;
len = 5 * INCH;
tlen = 2 * INCH;
wall = 3;

part = "tube"; //[tube, collar]

if (part == "tube") window_tube();

module window_tube() {
    tube(od = dia, l = len-tlen, wall = wall, anchor = BOT) {
    
    diff()
        attach(TOP,BOT) {
            acme_threaded_rod(d = dia, l =  tlen, pitch = 5, starts = 4, blunt_start = true, anchor = BOT);
            cyl(d = dia)
        }



    }


}