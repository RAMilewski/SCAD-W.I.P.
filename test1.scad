    // ==========================================================
    // Rectangular Cover Plate with Sidewalls
    // ==========================================================

    include <BOSL2/std.scad>
$fn = 360;
$fs = 0.4; 
$fa = 1;

squircle(100, 0.50, $fn=360);
up(2) squircle(100, 0.50);
up(4) squircle(100, 0.50, $fa=1, $fs=0.4);
