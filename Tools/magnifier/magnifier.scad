include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

$fn = 288;

d_lens = 128;
z_ring = 5;
lip = 3;
chamfang = 11;

//back_half( s = 400) 
arm();


module ring(is_top) {
    d_hole = is_top ? 3.2 : 4;  
    diff() {
        cyl(d = d_lens + lip * 6, h = 5, rounding1 = 1.5, teardrop = true){
            tag("remove") cyl(d = d_lens - lip * 2, h = z_ring); //center hole
            tag("remove") position(TOP) cyl(d = d_lens, h = 2, chamfer1 = lip, chamfang = chamfang, anchor = TOP);
            tag("remove") zrot_copies(n = 6, d = d_lens + lip * 3) cyl(d = d_hole, h = z_ring);
            if (is_top) { 
                tag("remove") position(BOT) zrot_copies(n = 6, d = d_lens + lip * 3) cyl(d = 5.6, h = 3.2, anchor = BOT);
            }
        }
    }
}

module arm() {
    hirth(n = 36, id = 5, od = 25, chamfer = 0.49);
}