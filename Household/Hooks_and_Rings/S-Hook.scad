include <BOSL2/std.scad>

/* [Config] */
stem  =  35;        // [1:1:200]
width =  4;         // width/dia of hook cross section
height = 4;         // height of hook cross section
rounding =  0.5;    // edge rounding radius
is_round = false;   // true make a round cross section hook

/* [Top Loop] */
r1 = 5;          // [2:0.5:30]
arc1 = 180;      // [45:1:270]
stem1 = 1;       // [1:1:50]   
r_tail1 = 0;     // [0:1:50]
arc_tail1 = 0;   // [0:1:180] 

/* [Bottom Loop] */
r2 = 5;          // [2:0.5:30]
arc2 = 180;      // [45:1:270]
stem2 = 1;       // [1:1:50]   
r_tail2 = 0;     // [0:1:50]
arc_tail2 = 0;   // [0:1:180] 

/* [Hidden] */
$fn = 72;

shape = is_round ? circle(d=width) : rect([width,height],rounding = rounding);

path1 = turtle(["setdir", 90, "ymove",stem/2, "arcleft",r1+width/2,arc1, "move",stem1, "arcright",r_tail1,arc_tail1]);
path_sweep(shape,path1);

path2 = turtle(["setdir", -90, "ymove",-stem/2, "arcleft",r2+width/2,arc2, "move",stem2, "arcright",r_tail2,arc_tail2]);
path_sweep(shape,path2);

if (is_round) {
    move(path1[len(path1)-1]) sphere(d=width);
    move(path2[len(path2)-1]) sphere(d=width);
} else {
    move(path1[len(path1)-1]) cyl(d = width, h = height, rounding = rounding);
    move(path2[len(path2)-1]) cyl(d = width, h = height, rounding = rounding);
}

/* */