include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

/* [Top Loop] */
loop  =   5;        // radius of first hook curve
arc   =  220;       // angle of first hook curve
rev1 = true;        // reverse tail on first curve
rtail = 9;          // radius of first tail
arc_tail = 90;      // angle of first tail

/* [Bottom Loop] */
loop2  =  5;        // radius of second hook curve
arc2  =  220;       // angle of second hook curve
rev2 = true;        // reverse tail on second curve
rtail2 = 9;         // radius of second tail
arc_tail2 = 45;     // angle of second tail

/* [Config] */
is_round = false;   // true make a round cross section hook
is_S = true;        // false makes a c-hook
stem  =  0;         // length of straight segment
width =  3;         // width of hook
height = 6;         // height of hook
round =  0.001;       // edge rounding radius


if (is_S) s_hook(); else c_hook();

module s_hook() {
    hook(loop, arc, stem, width, height); 
    
    if (rev1) move(polar_to_xy(loop, arc)) marker(3);
/*f
        zrot(arc-180) hook(rtail, -arc_tail, 0, width, height);
/* */
    move([loop + loop2, -stem]) rotate([180,180]){
        hook(loop2, arc2, 0, width, height);

        if (rev2) move(polar_to_xy(rtail2 + loop2, arc2)) marker(3);
/*            zrot(arc2-180) hook(rtail2, -arc_tail2, 0, width, height);
/* */
    }
}
module c_hook() {
     hook(loop, arc, stem, width, height);
    move = loop - loop2;
    translate([move,-stem,0]) rotate([180,0,0])
        hook(loop2, arc2, 0, width, height);
}



module hook(loop, arc, stem, width, height) {

    $fn = 64;

    //Loop
    shape = right(loop, is_round ? circle(d = width) : rect([width,height], rounding = width/5));
    rotate_sweep(shape, arc);
    
    //Round the end 
    vnf_polyhedron(move(polar_to_xy(-loop,arc-180), is_round ? sphere(d=width) 
        : cyl(h=height, d=width, rounding=round)));
               
    //Stem 
    if (stem > 0) {
        move([loop,-stem/2])
        if (is_round) ycyl(h=stem, d=width); 
        else cuboid([width,stem,height],rounding = round, edges = "Y");   
    }  
}

module marker(dia) {
    $fn = 72;
    color("red") cyl(d = dia, h = height + 1);
}
