include <BOSL2/std.scad>

cuboid(50, rounding = 5, edges = TOP, $fn = 64){
    position(TOP) color ("#153af1") text3d("TOP", center = true);
    attach(FWD) color ("#153af1") text3d("FWD", center = true, anchor = BOT);
    attach(RIGHT) color ("#153af1") text3d("RIGHT", center = true);
}