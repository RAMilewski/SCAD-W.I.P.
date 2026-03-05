include<BOSL2/std.scad>
include<BOSL2/threading.scad>

height = 8;

diff(){
    cyl(d = 30, h = height, anchor = BOT,  $fn = 64)
        tag("remove") position(BOT) 
            #threaded_rod(d = 25, l = height, pitch = 4, internal = true, bevel = false, anchor = BOT, $slop = 0.1, $fn = 64);

}