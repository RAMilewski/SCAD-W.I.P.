include <BOSL2/std.scad>


brand = 0; //[0:Overture C, 1:Polymaker C, 2:ColorFabb P, 3:ColorFabb C, 4:Duramic3D P, 5:Duramic3d C, 6:Gizmo-Dorks P]

/* [Hidden] */
$fn = 72;

disc_od = 0;
reel_hole = 1;
wall = 2;

spool = [
        //[DiscDia, ReelHoleDia, Sidewall]
        [60, 54.5, 3.5],    // Overture(C)
        [60, 54.5, 3.5],    // Polymaker(C)
        [60, 53, 3.5],      // ColorFabb(P)
        [60, 56, 3.5],      // ColorFabb(C)
        [60, 55.5, 3.5],    // Duramic3D(P)
        [60, 53.5, 3.5],    // Duramic3d(C)
        [60, 56.5, 3.5]     // Gizmo-Dorks(P)
];

hyg_dia = 42;

mount = spool[brand];

echo(spool[brand]);

tube(od = mount[disc_od], id = hyg_dia, h = 1.5)
    position(TOP) {
        diff() {
            union() {
                tube(od1 = mount[reel_hole], od2 = mount[reel_hole]-1, h = 2 * mount[wall], wall = 1.5, anchor = BOT)
                    position(TOP) rounding_cylinder_mask(d = mount[reel_hole]-1, rounding = 1);
                up (mount[wall]+1) torus(r_maj = mount[reel_hole]/2-1, r_min = 1.5);
            }
            zrot_copies(n = 3) tag("remove") cuboid([mount[disc_od],3,8], anchor = BOT);
        }
    }
    