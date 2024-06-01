include <BOSL2/std.scad>

$fn = 72;

dmaj = 50; 
dmin = 10;
h = 10;
hexwall = 0.5;
ringwall = 2;
thin = 2;


region = circle(d = dmaj + dmin, $fn=72);

diff() {
    grid_copies(spacing=dmin - 3 * hexwall, stagger=true, inside=region)
        zrot(180/6) hex(dmin,h,0.5);
    tube(od = dmaj, h = h, wall = ringwall);
    tag("remove") tube(id = dmaj, h = h+1, wall = dmin);
    tag("remove") down(thin/2) wedge([dmaj, dmaj, h-thin], center = true, spin = 90);
}

module hex(dmin,h,hexwall) {
    tag_scope()
    diff() {
        cyl(d = dmin, h = h, $fn = 6)
            tag("remove") cyl(d = dmin - 2 * hexwall, h = h + 0.1, $fn = 6);
    }
}



/*

hexregion = circle(r=50.01,$fn=6);
grid_copies(spacing=10, stagger=true, inside=hexregion)
  union() {   // Needed for OpenSCAD 2021.01 as noted above
    ref_v = (unit([0,0,50]-point3d($pos)) + UP)/2;
    half_of(v=-ref_v, cp=[0,0,5])
        zrot(180/6)
            cylinder(h=20, d=10/cos(180/6)+0.01, $fn=6);
  }

  */
