include <BOSL2/std.scad>
include <BOSL2/isosurface.scad> 


v_size = 1;
b_box = [[-35,-20,-25], [35,22,40]];
headZ = 23;


metaballs([
    scale([1.5,1,1]),    mb_disk(18,16),                //body
    left(10)* up(14),    mb_disk(3,5, influence = .5),  //neck shim
    left(10) * up(headZ),   mb_sphere(10, cutoff=11),   //head
    left(26) * up(30),   mb_sphere(5, negative = true, cutoff = 8),
    
    left(15) * up(headZ - 1) * fwd(5), mb_disk(1,2, cutoff = 4),       //cheek bulge
    left(15) * up(headZ - 1) * back(5), mb_disk(1,2, cutoff = 4),       //cheek bulge
     //beak
    left(23) * up(headZ) * zscale(0.4)* yrot(90), mb_capsule(12,3, cutoff = 5),
    left(18) * up(headZ), mb_disk(2,4),
    left(15) * up(headZ) * xrot(90), mb_disk(2,4),
    left(22) * up(headZ+1) * scale([1.2,1,0.75]) , mb_sphere(2, cutoff = 3),
    //tail
    right(20) * up(8) * yscale(1.7) * yrot(35), mb_cyl(h = 15, r1 = 4, r2 = 0.5), 
    ], 
    v_size, b_box, show_box = false, show_stats = true);

