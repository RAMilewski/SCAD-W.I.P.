/*  Dial holder for Blue_6090 Industrial Laser Cutter Alignment
    Printing from Carbon or Glass Fiber filled filament recommended.
*/


include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 72;
wall = 3;
zdim = 12;   // Overall height
d1 = 9.6;    // Dial Indicator Clamp Dia.
d2 = 18;     // Lens Barrel Clamp Dia.
bridge = [50-d1/2-d2/2-2*wall+2, 1.5 * wall, zdim];

holder();

module holder() {
    diff() {
        // Dial Indicator Clamp
        tube(id = d1, wall = wall, h = zdim, anchor = BOT){
            position(BOT) tag("remove") cyl(h = zdim, d = d1, anchor = BOT);
            position(LEFT) right(2*wall) cuboid([3*wall,4*wall+2,zdim], rounding=zdim/2, edges="Y", except=RIGHT, anchor=RIGHT){
                position(FWD) left(1) tag("remove") screw_hole("M3", l = 2*wall, head = "socket", anchor = TOP, orient=FWD);
                // Sized for m3 heat-set threaded insert
                position(BACK) left(1) tag("remove") ycyl(d = 4, l=2*wall, anchor = BACK);
            }
            position(LEFT) tag("remove") cuboid([4*wall, 2, zdim]);
            // Connecting Bar
            position(RIGHT) left(1) cuboid(bridge, anchor = LEFT){
                //End fillets
                align([LEFT,RIGHT], inside = true) tag("keep") left(wall*3/4+$idx*1.5*wall) zrot($idx*180) cyl(d = 3*wall, h = zdim, anchor = BOT, $fn = 3);
                // Lens Barrel Clamp
                position(RIGHT) left(1) tube(id = d2, wall = wall+1, h = zdim, anchor = LEFT){
                    position(BOT) tag("remove") cyl(h = zdim, d = d2, anchor = BOT);
                    align(RIGHT, inside = true, shiftout = 3) tag("remove") cuboid([4*wall+3,15,zdim+1]);
                    position(RIGHT) left(3*wall) cuboid([4*wall,15+4*wall,zdim], rounding= zdim/2, edges="Y", except=LEFT, anchor=LEFT){
                        align([BACK+LEFT, FWD+LEFT], inside = true, shiftout = -0.2) tag("keep") left(3) xscale(4) cyl(h = zdim, d = 1.4, $fn=6);
                        position(FWD) right(2) tag("remove") screw_hole("M3", l = 20, head = "socket", anchor = TOP, orient=FWD);
                        // Sized for m3 heat-set threaded insert
                        position(BACK) right(2) tag("remove") ycyl(d = 4, l=2*wall, anchor = BACK);
                    }
                }
            }
        }
    }


}

 //left(10) fwd(50) zrot(90) ruler();