include <BOSL2/std.scad>
include <diag_weave_vnf.tex>
    
path = [for(y=[-30:30]) [ 20-3*(1-cos((y+30)/60*360)),y]];
down(31)linear_extrude(height=1)arc(r=23,angle=[0,360], wedge=true);
rotate_sweep(path, caps=true, texture=diag_weave_vnf, angle=360,
             tex_size=[10,10], convexity=12, tex_depth=2);