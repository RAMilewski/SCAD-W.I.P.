include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

<<<<<<< HEAD
ear_box = [[-7,-4,0],[7,7,35]];
=======
b_box = [[-7,-4,-15],[7,7,38]];
>>>>>>> 2e15af0064284eab8de0ac3324fc3bc4e030cf60
//b_box = [[-30,-30,-10],[35,30,50]];
ear_v_size = [0.25,0.25,0.75];
head = [0,0,17];

ear = [
    move(head), mb_cyl(h = 30, d1 = 3, d2 = 0.5),
    move(head) * up(1) * zscale(2), mb_sphere(5),
    move(head) * up(1) * zscale(1), mb_cyl(h = 28, d1 = 3, d2 = 0.5, influence = 0.01, cutoff = 5, negative = true),
    move(head) * up(1) * zscale(3.8), mb_sphere(5, influence = .1, cutoff = 4, negative = true),
<<<<<<< HEAD
    move(head) * fwd(5) * zscale(4), mb_sphere(5, influence = .5, cutoff = 5, negative = true),
    //move(head) * down(head.z), mb_sphere(50, cutoff = 10), 
];

//back_half() 
metaballs(ear,ear_box, ear_v_size, debug = true, show_stats = true);
//vnf_polyhedron(ear_vnf);
=======
    move(head) * fwd(3) * zscale(4), mb_sphere(5, influence = .5, cutoff = 5, negative = true),

    down(6), mb_sphere(10, cutoff = 12),
];

//back_half() 
ear_vnf = metaballs(ear,b_box, v_size, show_stats = true);
vnf_polyhedron(ear_vnf);
>>>>>>> 2e15af0064284eab8de0ac3324fc3bc4e030cf60
/* */