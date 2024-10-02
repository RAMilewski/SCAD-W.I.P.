include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 144;



path = arc(d = 30, angle = 90);
//stroke(path, width = .5);
mask = mask2d_roundover(2, mask_angle = 90, inset = 0);
path_sweep(zrot(180,mask), path, method = "natural", relaxed = false, closed = false);

bez = flatten([
    bez_begin([0,20],RIGHT,10),
    bez_end([20,0],BACK,10)
]);
bpath = bezpath_curve(bez);
path_sweep(zrot(180,mask), bpath, method = "natural", relaxed = false, closed = false);
     

zrot(45) mask2d_roundover(2, mask_angle = 90, inset = 0);

/*
 */