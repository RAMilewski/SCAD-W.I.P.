include <BOSL2/std.scad>

$fn=72;

color("skyblue")
scale([3,3,1]) {
difference() {
    cyl(d=28,h=3, anchor = BOT);
    up(2.5) Mchannel();
}
}

module Mchannel() {
    zrot_copies(n=4, r=7.2)
    zrot(-90)
    xflip_copy()
    right_half()
    xscale(0.8)
    text3d("M", h=.5, font="Nasalization", size=8, center=true, anchor=BOT);
}
