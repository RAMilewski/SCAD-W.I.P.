include <BOSL2/std.scad>

/* [Config] */
// cross section
cs =  1.5;         // [0.5:0.5:10]
// Z scale 
z_scale = 12;    // [1:1:12] 
// Cross Section Sides
sides = 4;       // [2:1:12]
//Shaft Length     
l_shaft  =  55;    // [1:1:200]
//
/* [Top Loop] */
//
//Loop Radius
ir_loop1  =  2;     // [1:1:100]
angle1   =  188;    // [0:1:270]
l_stem1 = 18;       // [0:1:50] tail stem length 
r_curl1 = 12;        // tail curve radius
angle_curl1 = 44;    // tail curve angle

/* [Bottom Loop] */
//Loop Radius
ir_loop2  =   3;     // [1:1:100]
//Loop Angle
angle2   =  270;    // [-270:1:270]
l_stem2 = 0;        // [0:1:25] tail stem length 
r_curl2 = 0;        // tail curve radius
angle_curl2 = 0;    // tail curve angle

/* [Hidden] */

$fn = 72;


//back_half()
s_hook(cs,z_scale,sides,l_shaft,ir_loop1,angle1,l_stem1,r_curl1,angle_curl1,
    ir_loop2,angle2,l_stem2,r_curl2,angle_curl2);

module s_hook(cs = 2, z_scale = 1, sides = 6, l_shaft = 25, 
    ir_loop1 = 5, angle1 = 180, l_stem1 = 0, r_curl1 = 0,  angle_curl1 = 0,
    ir_loop2 = 5, angle2 = 180, l_stem2 = 0, r_curl2 = 0,  angle_curl2 = 0) {

    r_loop1 = ir_loop1 + cs/2;
    r_loop2 = ir_loop2 + cs/2;

    assert(l_shaft>0,  "l_shaft must be > 0");
    assert(is_int(sides), "Number of sides must be an integer.");
    stem1 = l_stem1 <= 0 ? 1e-10 : l_stem1;
    stem2 = l_stem2 <= 0 ? 1e-10 : l_stem2;

    shape = sides > 2 ? yscale(z_scale, regular_ngon(sides, cs, align_side = FWD)) : yscale(z_scale, circle(cs));     

    path1 = turtle(["setdir", 90, "ymove",l_shaft/2, "arcleft",r_loop1,angle1, "move",stem1, "arcright",r_curl1,angle_curl1]);
    path_sweep(shape,deduplicate(path1));
    path2 = turtle(["setdir", -90, "ymove",-l_shaft/2, "arcleft",r_loop2,angle2, "move",stem2, "arcright",r_curl2,angle_curl2]);
    path_sweep(shape,deduplicate(path2));
  
    endcap = right_half(shape);
    move(path1[len(path1)-1]) rotate_sweep(endcap);
    move(path2[len(path2)-1]) rotate_sweep(endcap);
}

//fwd(25) left(50) up(4) ruler();

/* */