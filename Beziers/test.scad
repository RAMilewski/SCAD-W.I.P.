include<BOSL2/std.scad>

$fn=72;

// This file is a part of openscad. Everything implied is implied.
// Author: Alexey Korepanov <kaikaikai@yandex.ru>

echo(version=version());

// These are examples for the `roof` function, which builds
// "roofs" on top of 2d sketches. A roof can be constructed using
// either straight skeleton or Voronoi diagram (see below).
//
// Under the hood, to construct straight skeletons we use cgal,
// while for Voronoi diagrams we use boost::polygon.
//
// With the current implementation, computation of Voronoi diagrams
// is much faster (10x - 100x) than that of straight skeletons.


diff() {
    zscale(3) xscale(-1) roof(method = "straight", h = 3)
        text("ABCD EFG", size = 12, halign = "right", valign = "baseline", font = "Arial Black");
    tag("remove") up(3) cuboid([100,20,10], anchor = FWD+LEFT+BOT);
}   


fwd(20) {

$fa=1; $fs=0.4;
intersection() {
  cube([100,100,2],true);
  scale([1,1,3]) roof(convexity=6) text("Wow", font = "Arial Black");
}
}