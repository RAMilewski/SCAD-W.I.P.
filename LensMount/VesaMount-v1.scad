include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 64;
Vsize = [114,114,6];
Vmin = 75;
Vmaj = 100;
Vdia = 5;
lift = 30;
Lmin = 117;
Lmaj = 140;
Llen = 40;
ellipse = ellipse([Llen/2 - 5, Llen], $fn = 164);
clamp = [Llen/2, 20, 20];

 partition([200,200,250], 20, 200, "flat") ring();

module Vmount() {
    join_prism( ellipse,base="plane",base_d=Lmaj, fillet=lift/2.1, length = lift/2) {
        tag_scope()
        diff() {
            attach(BOT,TOP)
            down(01) cuboid(Vsize, rounding = 8, edges = "Z"){
                grid_copies(n = [2,2], size = Vmaj)
                    tag("remove") cyl(h = Vsize.z + 0.2, d = Vdia);
                grid_copies(n = [2,2], size = Vmin)
                    tag("remove") cyl(h = Vsize.z + 0.2, d = Vdia);
            
            }
        }
    }
}

module ring() {
    join_prism( ellipse,base="cyl",base_d=Lmaj, fillet=3.75, length = lift/2) {
        tag_scope()
        diff() {
            left(0.5)attach(TOP,TOP) Vmount();

            up(0.5) xcyl(h = Llen, d = Lmaj, rounding = 3, $fn = 144){
                tag("remove") xcyl(h = 46, d = Lmin);
            
            attach(BOT,TOP) down(10) cuboid(clamp, rounding = 5, edges = "Y")
                down(3) tag("remove") ycyl(h = clamp.y + 1, d = Vdia);
            }

        }
    }
}