include <BOSL2/std.scad>
include <BOSL2/turtle3d.scad>
include <BOSL2/screws.scad>

/* [Part] */
//to render
part = "base"; //[base,ring,foot]

/* [Ring] */
//which ring
is_top = false; 
d_lens = 128;
lip = 3;
chamfang = 11;

/* [Foot] */
droop = 0.6;    // [0.2:.05:1.2]
stance = 1.3;   // [1:0.1:2]
base = [d_lens * stance,10];

/* [Base] */
lift = 50;   // [10:5:100]
arc = 50;    // [20:5:90]
angle = 70;  // [10:5:90]
reach = 0;   // [0:5:50]

/* [Hidden] */ 
$fn = 72;


if (part == "base") base();
if (part == "ring") ring();
if (part == "foot") foot();



notch = (11.8 - base.y/2);
echo(UP+BACK);
module base() {
    back(droop * d_lens) foot();
    path = turtle3d(["setdir",UP, "zmove",lift, "arcxrot",arc,angle * -1, "move",reach]);
    diff() {
        path_sweep(circle(base.y),path);
        move(path[len(path)-1]) xrot(20) yscale(1.1) spheroid(base.y+3) {
            //tag("remove") position(BACK) down(base.y/2) cuboid([4, base.y * 1.5 + 4, base.y]);
            xrot(180) fwd(4) screw_hole("M3,8",head="socket",counterbore=8,anchor=BOT);
    }
        tag("remove") move(path[len(path)-1]) xrot(20) 
            cyl(d = d_lens + lip * 6, h = 10, $fn = 288, anchor = FRONT);
    }
}

module foot() {
    path = catenary(base.x, droop = droop * d_lens);
    shape = circle(base.y);
        top_half(s = base.x * 2) union() {
            path_sweep(shape,path);
            move(path[0]) spheroid(base.y);
            move(path[len(path)-1]) spheroid(base.y);
        }
}


module ring(is_top) {
    d_hole = is_top ? 4.25 : 3.75;  
    z_ring = is_top ? 4 : 6;
    diff() {
        cyl(d = d_lens + lip * 6, h = z_ring, rounding1 = 1.5, teardrop = true){
            tag("remove") cyl(d = d_lens - lip * 2, h = z_ring); //center hole
            tag("remove") position(TOP) cyl(d = d_lens, h = 2, chamfer1 = lip, chamfang = chamfang, anchor = TOP);
            tag("remove") zrot_copies(n = 6, d = d_lens + lip * 3) cyl(d = d_hole, h = z_ring);
            if (is_top) { 
                tag("remove") position(BOT) zrot_copies(n = 6, d = d_lens + lip * 3) cyl(d = 5.6, h = 3.2, anchor = BOT);
            }
        }
    }
}


    
