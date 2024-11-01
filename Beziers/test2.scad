include <BOSL2/std.scad>
$fn = 72;

diff()
cuboid(20, rounding = 2, edges = [TOP,BACK], except = [FWD,BOT]) {
  attach(RIGHT+TOP,LEFT+FWD,inside=true,align=FWD) rounding_edge_mask(r1=2,r2=10, l = $edge_length-3);
  attach(LEFT+TOP,LEFT+FWD,inside=true,align=FWD)  rounding_edge_mask(r1=10,r2=2, l = $edge_length-3);
}