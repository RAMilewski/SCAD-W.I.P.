include <BOSL2/std.scad>
include <BOSL2/isosurface.scad> 

isovalue = 1;
voxel_size = .5;

h = 10;
r1 = 25;
r2 = 5;
r3 = 7;
c = r2+4;

//infl = EPSILON + 1 - $t;


vnf = metaballs([
    IDENT, mb_disk(h,r1),
    //left(r1), mb_sphere(r2,influence = EPSILON, negative = true, cutoff = r2),
    left(r1), mb_sphere(r2,influence = 5, negative = true, cutoff = c),
    ], 
    voxel_size, [[-r1,-r1,-h], [r1,r1,h]], isovalue);

diff() {
    //left_half(x = -12) 
    vnf_polyhedron(vnf);
        tag("remove") left(r1) yscale(1.1) cyl(h,r3, $fn = 32);
}