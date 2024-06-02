include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 64;
Vsize = [114,114,6];
Vmin = 75;
Vmaj = 100;
Vdia = 5;
lift = 35;
Lmin = 117;
Lmaj = 140;
Llen = 40;
ellipse = ellipse([Llen/2 - 5, Llen], $fn = 164);
clamp = [Llen/2, 30, 20];

 ring();

module Vmount() {
    diff() {
        tag_scope()
        cuboid(Vsize, rounding = 8, edges = "Z"){
            grid_copies(n = [2,2], size = Vmaj)
                tag("remove") #cyl(h = Vsize.z + 0.2, d = Vdia);
            grid_copies(n = [2,2], size = Vmin)
                tag("remove") #cyl(h = Vsize.z + 0.2, d = Vdia);
        
        }
    }
}

module ring() {
    join_prism( ellipse,base="cyl",base_d=Lmaj, fillet=3, length = 30) {
        tag_scope()
        diff() {
            attach(TOP,TOP) Vmount();

            xcyl(h = Llen, d = Lmaj, rounding = 5){
                tag("remove") xcyl(h = 46, d = Lmin);
            
            attach(BOT,TOP) down(10) cuboid(clamp, rounding = 5, edges = "Y")
                down(3) tag("remove") #ycyl(h = clamp.y + 1, d = Vdia);
            }

        }
    }
}