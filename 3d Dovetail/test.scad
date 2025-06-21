include <BOSL2/std.scad>

$fn = 72;

cuboid([200,25,2], anchor = BOT+BACK, rounding = 1, edges = FWD){
  position(BACK+TOP) rot([180,-90,0]) fillet(r = 10, l = 200);
  position(BACK+BOT) cuboid([200,2,25], rounding = 1, edges = TOP, anchor = BOT+FWD);
}