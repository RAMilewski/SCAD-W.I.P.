include <BOSL2/std.scad>
include <BOSL2/isosurface.scad> 

stats = false; // [true,false]
debug = false; // [true,false]
box =   false; // [true,false]

v_size = 1;
i_value = 1;
b_box =   [[-30, -20, -11], [35, 20, 35]];

/* [Hidden] */
headZ = 21;

spec =[
    scale([1.5,1,1]),       mb_disk(18,16),                //body
    left(10)* up(14),       mb_disk(3,5, influence = .5),  //neck shim
    left(10) * up(headZ),   mb_sphere(10, cutoff=11),   //head
    left(26) * up(30),      mb_sphere(5, negative = true, cutoff = 8),
    
    left(15) * up(headZ-1) * fwd(5),  mb_disk(1,2, cutoff = 4),       //cheek bulge
    left(15) * up(headZ-1) * back(5), mb_disk(1,2, cutoff = 4),       //cheek bulge
    // eye sockets
    left(18.5)*up(headZ+3)*fwd(4.5),  mb_sphere(1, influence = 0.5, negative = true, cutoff = 3),
    left(18.5)*up(headZ+3)*back(4.5), mb_sphere(1, influence = 0.5, negative = true, cutoff = 3),
    //beak
    left(23) * up(headZ) * zscale(0.4)* yrot(90), mb_capsule(12,3, cutoff = 5),
    left(18) * up(headZ), mb_disk(2,4),
    //left(15) * up(headZ) * xrot(90), mb_disk(2,4),
    left(22) * up(headZ+1) * scale([1.2,1,0.75]) , mb_sphere(2, cutoff = 3),
    //tail
    right(20) * up(8) * yscale(1.7) * yrot(35), mb_cyl(h = 15, r1 = 4, r2 = 0.5), 
    ];

    metaballs(spec, b_box, v_size, isovalue = i_value, show_box = box, debug = debug, show_stats = stats);
    //eyes
    yflip_copy() left(16.5) up(headZ+3) fwd(4.5) sphere(1.2, $fn = 32);

