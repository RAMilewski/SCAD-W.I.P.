include<BOSL2/std.scad>
include<BOSL2/threading.scad>
include<BOSL2/screws.scad>

$fn = 72;

threaded = 10;
csize=([48,undef,70-threaded]);
wall = 4;
thinwall = 1.5;
ring = 3;

 post(); right(60) mount();

module post() {
    //back_half(s = 200)
    diff() {
        cyl(d = csize.x + ring
        , h = ring, rounding = ring/2, teardrop = true, anchor = BOT) {
            attach(TOP,BOT) tube(od = csize.x, h = csize.z, wall = thinwall)
                attach(TOP,BOT) tube(od = csize.x, h = threaded, wall = wall)  
                    tag("remove") position(TOP)
                        acme_threaded_rod(d = csize.x - wall, l=threaded, pitch=5, starts=3, 
                            internal = true,  blunt_start = false, $fa=1, $fs=1, $slop = .3, anchor = TOP);
        }
    }
}

module mount(){
    diff() {
        cyl(d = csize.x + 10, h = ring, rounding = ring/2, teardrop = 2, anchor = BOT){
            attach(TOP,BOT) 
                acme_threaded_rod(d = csize.x - wall, l=threaded, pitch=5, starts=3,
                    blunt_start = false, end_len2 = 2, $fa=1, $fs=1, anchor = TOP)
                position(TOP)
                    screw_hole("#6,1",head="flat",head_oversize = 2, counterbore=10,anchor=TOP);
            }
    }
}