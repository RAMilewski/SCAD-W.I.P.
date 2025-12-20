include<BOSL2/std.scad>

rotate([0, 90, 0]) diff() 
  cube([70, 50, 10], center=true)
  corner_profile(TOP+LEFT, r=10) mask2d_roundover(2)
;
