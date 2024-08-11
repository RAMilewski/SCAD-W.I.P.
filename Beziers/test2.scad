
include<BOSL2/std.scad>
include<BOSL2/beziers.scad>
include<BOSL2/rounding.scad>

side_bez = [[20,0], [40,40], [-10,70], [20,100]];
side = bezpath_curve(side_bez, splinesteps = 32);

//stroke(side);

$fn = 32;
cyl(h=10, d=10, rounding1 = 2, texture = "bricks", teardrop = 30, anchor = BOT); //show_anchors();


/*
//
msize = side_bez[0].x; // size of the base
d = size * 0.8;       // intermediate control point distance
theta = 65;           // adjusts layer "wavyness".
bz = 5*cos(theta);    // offset to raise layer curve minima above z = 0;
                 
layer_bez = flatten([
    bez_begin ([-size,0,bz],  90, d, p=theta),
    bez_tang  ([0, size,bz],   0, d, p=theta),
    bez_tang  ([size, 0,bz], -90, d, p=theta),
    bez_tang  ([0,-size,bz], 180, d, p=theta),    
    bez_end   ([-size,0,bz], -90, d, p=180 - theta)
]);

*/