include <BOSL2/std.scad>
$fs=0.25;$fa=0.25;


//back_half()

scale(3) diff()
    cuboid([21,24,6], rounding = 1, teardrop = true)
        attach(TOP, LEFT, inside=true)
            hemicyl(20, 10, thickness = 5, rounding=-1, end_rounding=-1, extra=1);
