include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

b_box = [[7,-4,3],[7,7,38]];
//b_box = [[-30,-30,-10],[35,30,50]];
v_size = 1;
head = [0,0,20];

ear = [
    move(head), mb_cyl(h = 30, d1 = 3, d2 = 0.5),
    move(head) * up(1) * zscale(2), mb_sphere(5),
    move(head) * up(1) * zscale(1), mb_cyl(h = 28, d1 = 3, d2 = 0.5, influence = 0.01, cutoff = 5, negative = true),
    move(head) * up(1) * zscale(3.8), mb_sphere(5, influence = .1, cutoff = 4, negative = true),
    move(head) * fwd(5) * zscale(4), mb_sphere(5, influence = .5, cutoff = 5, negative = true),
];

earhole = [

];


//back_half() 
metaballs(ear,b_box, v_size, isosurface = [0.9,1], show_stats = true, anchor = BOT);