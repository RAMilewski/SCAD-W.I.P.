include <BOSL2/std.scad>

/* [Config] */
or =  2;         // dia of hook cross section
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

s_hook(or,sides,l_shaft,16,r_loop1,angle1,l_stem1,r_curl1,angle_curl1,
    r_loop2,angle2,l_stem2,r_curl2,angle_curl2);

module s_hook(or = 2, sides = 6, l_shaft = 25, $fn = 32,
    r_loop1 = 5, angle1 = 180, l_stem1 = 0, r_curl1 = 0,  angle_curl1 = 0,
    r_loop2 = 5, angle2 = 180, l_stem2 = 0, r_curl2 = 0,  angle_curl2 = 0) {

    assert(l_shaft>0,  "l_shaft must be > 0");
    assert(is_int(sides), "Number of sides must be an integer.");

    stem1 = l_stem1 <= 0 ? 1e-10 : l_stem1;
    stem2 = l_stem2 <= 0 ? 1e-10 : l_stem2;

    shape = sides > 2 ? regular_ngon(sides, or, align_side = FWD) : circle(or);     

    path1 = turtle(["setdir", 90, "ymove",l_shaft/2, "arcleft",r_loop1,angle1, "move",stem1, "arcright",r_curl1,angle_curl1]);
    path_sweep(shape,path1);
    path2 = turtle(["setdir", -90, "ymove",-l_shaft/2, "arcleft",r_loop2,angle2, "move",stem2, "arcright",r_curl2,angle_curl2]);
    path_sweep(shape,path2);
  
    endcap = right_half(shape);
    move(path1[len(path1)-1]) rotate_sweep(endcap);
    move(path2[len(path2)-1]) rotate_sweep(endcap);
}

/* */