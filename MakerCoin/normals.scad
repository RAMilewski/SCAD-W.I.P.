include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

r1 = 25;    // Major radius of the disc
r2 = 5;     // Rounding radius of the disc edge

edge = flatten([
        bez_begin(cylindrical_to_xyz(r1+r2,0,r2),FWD,4),
        bez_tang (cylindrical_to_xyz(r1,-14.5,0),DOWN,4.1),
        bez_tang (cylindrical_to_xyz(r1+r2,0,-r2),BACK,4),
        bez_tang (cylindrical_to_xyz(r1,14.5,0),UP,4.1),
        bez_end  (cylindrical_to_xyz(r1+r2,0,r2),BACK,4)
]);

edgepath = bezpath_curve(edge, splinesteps = 8);
stroke(edgepath, closed=true, width=0.25);
echo("edgepath: ",len(edgepath));

sampled = resample_path(edgepath, n=8, closed = true);
color("blue" )move_copies(sampled) sphere(0.2,$fn=16);

mask =  mask2d_roundover(2, mask_angle = 90, inset = 0, $fn = 64);
 *path_sweep(mask, edgepath, method = "manual", normal = FWD, relaxed = true, closed = true);

normals = path_normals(edgepath,closed=true);
color("purple")
    for(i=[0:len(normals)-1])
        stroke([edgepath[i]-normals[i], edgepath[i]+normals[i]],width=.1, endcap2="arrow2");



