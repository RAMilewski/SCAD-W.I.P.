include <BOSL2/std.scad>
include <diag_weave_vnf.tex>

show_profile = false;  //[true,false]

/* [Profile] */
r_base = 55;
shape = [1.2,0.75,3.5];
tex_size = [20,20];

r_top = shape.x * r_base;
z_top = shape.z * r_base;
bulge = shape.y * r_base;

$fn = 64;
floor = 2;

bez =[[r_base,0], [r_base+bulge,z_top/2], [r_top+bulge,2*z_top/3],  [r_top,z_top]];

//debug_bezier(bez);


path = bezpath_curve(bez, splinesteps = 256);

if (show_profile) {
    stroke(path, width = .5);
} else {
    cyl(r = r_base + 1.5, h = floor, rounding1 = 1, teardrop = true, $fn = 144,anchor = BOT);
    //up(1) rotate_sweep(path,180, texture = diag_weave_vnf, tex_reps = tex_reps, tex_depth = -1.5);
    up(1) rotate_sweep(path, caps=true, texture=diag_weave_vnf, angle=360,
             tex_size=tex_size, convexity=12, tex_depth=5);
}

/*  */