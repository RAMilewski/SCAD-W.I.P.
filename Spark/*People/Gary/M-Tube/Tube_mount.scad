//  Spark Studio
//  Mount Plastic Tubes on Metal Shelf
//  by Richard
//

/*######################################################/*

    CONFIGURATION

/*######################################################*/

include <BOSL2/std.scad>

base = true;
flat = true;

module hide_variables () {}	// variables below hidden from Customizer

$fn=72;
eps = 0.01;
tube_id = 28;
tube_od = 32;
wall = 2;       //  Insert wall thickness
corner = wall / 2; //  Corner Radius
mount_od = tube_od + 2 * wall;           
floor = 2;      //Floor Thickness
d_btn = 12;     //Button Dia
h_btn = 3;      //Button Thickness
d_post = 6;     //Post Dia
h_post = 2.5;   //Post Height

h_ring = base ? 20: 15; //  Height of Ring
/*######################################################*/

tube_grip();
if (flat) flat();


/*######################################################/*

    MODULES

/*######################################################*/

module tube_grip() {
    diff() {
        tube(id = tube_od, wall = wall, h = h_ring) {
            if (base) {
                position(BOT) tube(od = tube_od + wall, id = tube_id, h = floor, anchor = BOT);
            }
            yrot_copies(n = 2) attach(TOP) rounding_cylinder_mask(d=mount_od, rounding = corner);
            attach(TOP) rounding_hole_mask(d=tube_od, rounding = corner);
            post();
        }
    }
}

module flat() {
    side = mount_od;
    right(side/4) 
    diff() {
        cuboid([side/2, side, h_ring], rounding = corner, except = LEFT) {
            left(side/4) tag("remove") cyl(d = side, h = h_ring + eps, rounding = corner, anchor = CENTER);
            attach(TOP) left(side/4) rounding_hole_mask(d=tube_od, rounding = corner);
           
        }
    }
}

module post() {
   
   position(RIGHT) xcyl(d = d_post, h = h_post, anchor = LEFT)
   position(RIGHT) xcyl(d = d_btn, h = h_btn, rounding= corner, anchor = LEFT );
}