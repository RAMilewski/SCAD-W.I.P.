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

bb = [[-r1,-r1,-h], [r1,r1,h]];
vol = (-bb[0].x+bb[1].x) * (-bb[0].y+bb[1].y) * (-bb[0].z+bb[1].z);
echo(vol);
auto = log(vol/5000);
echo(auto, norm([1,1]));

vnf = metaballs([
    IDENT, mb_disk(h,r1),
    //left(r1), mb_sphere(r2,influence = EPSILON, negative = true, cutoff = r2),
    left(r1), mb_sphere(r2,influence = 5, negative = true, cutoff = c),
    ], 
    auto, bb, isovalue);

diff() {
    //left_half(x = -12) 
    vnf_polyhedron(vnf);
        tag("remove") left(r1) yscale(1.1) cyl(h,r3, $fn = 32);
}