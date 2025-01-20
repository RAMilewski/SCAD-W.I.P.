include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
control = [[30,0],[50,20],[-40,30],[100,50],[10,70]];
weights = [1,1,1,2,1];
mult    = [1,2,1];
debug_nurbs(control, degree = 2, type = "clamped",
  weights = weights,
  mult = mult,
  show_knots = true
);



/*

/* */