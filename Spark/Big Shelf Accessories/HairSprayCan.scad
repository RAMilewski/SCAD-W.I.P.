include <BOSL2/std.scad>
$fn = 72;
A = 12;
B = 6;      //dia of post shaft
C = 2.5;    //height of post shaft
D = 3;      //Wall thickness

can_r = 30; //ir of the can well.
can_z = 50;  //depth of can well.

base = [70, D, can_z]; //Shelf-side wall


well()
    position(RIGHT+BOT) up(can_z-base.z/2) double_mount();
    support();

//back(1.75 * INCH/2) right(42) yrot(90) ruler();

module well() {
    attachable(anchor = CENTER, spin = 0, orient = UP, size = [2*(can_r+D), 2*(can_r+D), can_z]) {
        diff() {
            hull() {
                cyl(h = can_z, r = can_r+D, rounding = D/2, teardrop = true);
                right(can_r+D) zrot(90) cuboid(base, rounding = D/2);
            }
            tag("remove") up(D) cyl(h = can_z-D, r = can_r, rounding2 = -3);
        }
        children();
    };
}


module double_mount(){
    attachable(anchor = CENTER, spin = 090, orient = UP, size = base) {
        union() {
            cuboid(base, rounding = D/2){
                position(FWD) xcopies(n = 2, spacing = 1.75 * INCH) post();
            }
        }
        children();
    }
}


module post() {
    diff() {
        hull() { zcopies(n = 2, spacing = B/2) ycyl(d = B, h = C, anchor = BACK); }
        position(FWD) fwd(1) top_half(z = -A/2.5) ycyl(d = A, h = D+2, rounding = 0.5, anchor = BACK);
        //tag("remove") #hull() { zcopies(n = 2, spacing = B) #ycyl(d = 0.2, h = C+D+2, anchor = BACK); }
    }
}


module support() {
    right(can_r + 2*D + C + 3.5) down(can_z/2)
    ycopies(n = 2, spacing = 1.75 * INCH) prismoid([10,A], [D+2,B], h = can_z/2 -5, shift = [-2.5,0]);
}