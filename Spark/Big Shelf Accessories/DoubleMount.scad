include <BOSL2/std.scad>
$fn = 72;
A = 12;
B = 6;      //dia of post shaft
C = 2.5;    //height of post shaft
D = 3;      //Wall thickness

base = [60, D, 20]; //Shelf-side wall





double_mount();


module double_mount(){
    attachable(anchor = CENTER, spin = 0, orient = UP, size = base) {
        union() {
            cuboid(base, rounding = D/2, except = BOT){
                position(FWD) xcopies(n = 2, spacing = 1.75 * INCH) post();
            }
        }
        children();
    }
}


module post() {
    ycyl(d = B, h = C, anchor = BACK)
    position(FWD) ycyl(d = A, h = C, rounding = 0.5, anchor = BACK);
}