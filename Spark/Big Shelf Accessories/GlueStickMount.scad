include <BOSL2/std.scad>
$fn = 72;
A = 12;
B = 6;      //dia of post shaft
C = 2.5;    //height of post shaft
D = 3;      //Wall thickness
base = [70, 25, D]; //Shelf-side wall

gsw_r = 15.25; //ir of the glue stick well.
gsw_z = 35;  //height of glue stick well.



well()
    position(RIGHT+BOT) up(gsw_z) mount();



module well() {
    attachable(anchor = CENTER, spin = 0, orient = UP, size = [2*(gsw_r+D), 2*(gsw_r+D), gsw_z]) {
        diff() {
            hull() {
                cyl(h = gsw_z, r = gsw_r+D, rounding = D/2, teardrop = true);
                right(gsw_r/2+D) cuboid([gsw_r,base.y,gsw_z], rounding = D/2, except = RIGHT);
            }
            tag("remove") up(D) cyl(h = gsw_z-D, r = gsw_r, rounding2 = -3);
        }
        children();
    };
}


module mount(){
    attachable(anchor = CENTER, spin = 180, orient = LEFT, size = base + [base.y/4,0,0], offset = [-base.y/8,0,0]) {
        union() {
            cuboid(base, rounding = D/2, edges = [TOP,BOT], except = [LEFT,TOP+RIGHT]){
                position(LEFT+BOT) post();
                position(LEFT) xscale(0.5) left_half() cyl(d = base.y, h = base.z, rounding = D/2);
            }
        }
        children();
    }
}


module post() {
    cyl(d = B, h = C, anchor = TOP)
    position(BOT) cyl(d = A, h = C, rounding = 0.5, anchor = TOP);
}