include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn=72;
width = 3;
height = 2;
test = true;
loop = 20;

shape = right(loop, test ? rect([width,height],rounding = width/5) : circle(d = width));
rotate_sweep(shape, 180);