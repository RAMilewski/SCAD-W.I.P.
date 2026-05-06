include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>


$fn = 144;


diff() {
    cuboid([80,60,20], rounding = 5, except = [BOT,TOP+RIGHT])
          edge_profile(TOP+RIGHT, excess=10)
            mask2d_smooth(cut=15, splinesteps = 64);

}