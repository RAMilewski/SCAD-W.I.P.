include <BOSL2/std.scad>

$fn = 72;


cuboid([80,15,13], rounding = 3, except = FWD)
    align(FWD,[LEFT,RIGHT]) cuboid([20,20,13], rounding = 3, except = BACK);
