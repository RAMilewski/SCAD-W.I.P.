include <BOSL2/std.scad>

/* [Config] */
cs =  2;         // width of hook cross section
z_scale = 1;      // z-axis scale factor 
sides = 6;       // shape of hook cross section     
l_shaft  =  35;    // length of straight segment

/* [Top Loop] */
r_loop1  =  5;     // hook curve radius
angle1   =  180;    // hook curve angle
l_stem1 = 4;        // tail stem length 
r_curl1 = 0;        // tail curve radius
angle_curl1 = 0;   // tail curve angle

/* [Bottom Loop] */
r_loop2  =   5;     // hook curve radius
angle2   =  180;    // hook curve angle
l_stem2 = 4;        // tail stem length 
r_curl2 = 0;        // tail curve radius
angle_curl2 = 0;   // tail curve angle

/* [Hidden] */

$fn = 72;


//back_half()
s_hook(cs,z_scale,sides,l_shaft,r_loop1,angle1,l_stem1,r_curl1,angle_curl1,
    r_loop2,angle2,l_stem2,r_curl2,angle_curl2);

module s_hook(cs = 2, z_scale = 1, sides = 6, l_shaft = 25, 
    r_loop1 = 5, angle1 = 180, l_stem1 = 0, r_curl1 = 0,  angle_curl1 = 0,
    r_loop2 = 5, angle2 = 180, l_stem2 = 0, r_curl2 = 0,  angle_curl2 = 0) {

    assert(l_shaft>0,  "l_shaft must be > 0");
    assert(is_int(sides), "Number of sides must be an integer.");

    stem1 = l_stem1 <= 0 ? 1e-10 : l_stem1;
    stem2 = l_stem2 <= 0 ? 1e-10 : l_stem2;

    shape = sides > 2 ? yscale(z_scale, regular_ngon(sides, cs, align_side = FWD)) : yscale(z_scale, circle(cs));     

    path1 = turtle(["setdir", 90, "ymove",l_shaft/2, "arcleft",r_loop1,angle1, "move",stem1, "arcright",r_curl1,angle_curl1]);
    path_sweep(shape,path1);
    path2 = turtle(["setdir", -90, "ymove",-l_shaft/2, "arcleft",r_loop2,angle2, "move",stem2, "arcright",r_curl2,angle_curl2]);
    path_sweep(shape,path2);
  
    endcap = right_half(shape);
    move(path1[len(path1)-1]) rotate_sweep(endcap);
    move(path2[len(path2)-1]) rotate_sweep(endcap);
}

/* */