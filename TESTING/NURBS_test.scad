include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

$fn = 64;

control = [[30,0],[50,20],[-40,30],[100,50],[10,70]];
curve = bezpath_close_to_axis(nurbs_curve(control,3,splinesteps=64, type = "clamped"),"Y",N=4);
stroke(curve);
color("blue")move_copies(control) circle(r=1.5,$fn=16);
label(control);

//rotate_sweep(curve,360);


module label(list)
for (i = [0:len(list)-1]) {
  move(list[i]) text(str(i),5);
} 

/*
pts = nurbs_curve(control,5,u=[0,0.2,0.4,0.8,1]);
color("red")move_copies(pts) circle(r=1.5,$fn=16);

/* */