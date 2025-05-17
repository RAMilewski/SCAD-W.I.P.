include <BOSL2/std.scad>


$fn = 288;

diff() {
    cuboid ([90,90,10], rounding = 2, except = BOT, anchor = BOT)
    tag("remove") position(TOP) down(8) ycyl(h = 90.1, d = 8 * INCH, anchor = BOT);
}