include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

//b_box = [[-30,-30,20],[35,30,50]];
b_box = [[-30,-30,-10],[35,30,50]];
v_size = 1;
head = [-8,0,22];

rabbit = [
    //body
    move([20,0,10]) * yscale(0.8), mb_sphere(10),
    move([5,0,10]) * yscale(0.8), mb_sphere(5),
    //head
    move(head) * xscale(1.2) * yrot(-20), mb_disk(h = 3, r = 5, cutoff = 5), 
    move(head + [0,0,3]) * xrot(90), mb_disk(h = 3, r = 5, cutoff = 5),
    move(head + [-8,0,-2]) * yrot(60), mb_cyl(h = 5, d1 = 2, d2 = 4), 
    //neck
    move(head + [8,0,-4]) * yscale(0.8) * yrot(-45), 
        mb_disk(h = 1.8, r = 1, influence = 0.8, cutoff = 8),
];

metaballs(rabbit,b_box, v_size, show_stats = true);