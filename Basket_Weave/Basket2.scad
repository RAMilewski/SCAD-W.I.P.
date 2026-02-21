include <BOSL2/std.scad>
include <diag_weave_vnf.tex>

show_profile = false;  //[true,false]

/* [Profile] */
r_base = 75;
shape = [1.5,1.1,1];
tex_size = [30,30];

r_top = shape.x * r_base;
bulge = shape.y * r_base;
z_top = shape.z * r_base;

$fn = 64;
floor = 2;

bez =[[r_base,0], [bulge,z_top/2], [bulge,2*z_top/3],  [r_top,z_top]];

path = bezpath_curve(bez, splinesteps = 256);

if (show_profile) {
    debug_bezier(bez);
} else {
    cyl(r = r_base + 1.5, h = floor, rounding1 = 1, teardrop = true, $fn = 144,anchor = BOT);
    //up(1) rotate_sweep(path,180, texture = diag_weave_vnf, tex_reps = tex_reps, tex_depth = -1.5);
    up(1) rotate_sweep(path, caps=true, texture=diag_weave_vnf, angle=360,
             tex_size=tex_size, convexity=12, tex_depth=5);
}

/*  */