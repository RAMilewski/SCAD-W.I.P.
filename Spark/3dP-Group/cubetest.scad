include <BOSL2/std.scad>

$fn=(64);


recolor("red")  cuboid(10) show_anchors()
position(RIGHT) recolor("blue") xcyl(h= 10, d = 5, anchor = LEFT+TOP);