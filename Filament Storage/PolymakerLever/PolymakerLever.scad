include<BOSL2/std.scad>

$fn = 72;

cuboid([18,5,25], rounding = 2.5, edges = "Z", except = (RIGHT)){
    position(RIGHT) cyl(h = 25, r = 2.5)
        position(CTR) zrot(-30) cuboid([50,5,25], rounding = 2.5, edges = "Z", except = LEFT, anchor = LEFT);
}