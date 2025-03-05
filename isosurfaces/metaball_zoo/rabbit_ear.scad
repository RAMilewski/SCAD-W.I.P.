include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

ear_box = [[-7,-4,0],[7,7,35]];
//b_box = [[-30,-30,-10],[35,30,50]];
ear_v_size = [0.25,0.25,0.75];
head = [0,0,17];

ear = [
    move(head), mb_cyl(h = 30, d1 = 3, d2 = 0.5),
    move(head) * up(1) * zscale(2), mb_sphere(5),
    move(head) * up(1) * zscale(1), mb_cyl(h = 28, d1 = 3, d2 = 0.5, influence = 0.01, cutoff = 5, negative = true),
    move(head) * up(1) * zscale(3.8), mb_sphere(5, influence = .1, cutoff = 4, negative = true),
    move(head) * fwd(5) * zscale(4), mb_sphere(5, influence = .5, cutoff = 5, negative = true),
    //move(head) * down(head.z), mb_sphere(50, cutoff = 10), 
];

//back_half() 
metaballs(ear,ear_box, ear_v_size, debug = true, show_stats = true);
//vnf_polyhedron(ear_vnf);
/* */