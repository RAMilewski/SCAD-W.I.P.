include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

/* [Flags] */
debug  = true; // [true,false]
box    = false; // [true,false]
stats  = false; // [true,false]

/* [Voxel Size] */
vsize  = 1;

/* [Hidden] */

isoval = 1; 
legD1 = 4.6;
legD2 = 1;
spec = [
    // legs
    up(1)*fwd(8)*left(13), mb_cyl(d1=legD1, d2=legD2, h=20),
    up(1)*fwd(8)*right(10), mb_cyl(d1=legD1, d2=legD2, h=20),
    up(1)*back(8)*left(13), mb_cyl(d1=legD1, d2=legD2, h=20),
    up(1)*back(8)*right(10), mb_cyl(d1=legD1, d2=legD2, h=20),
    up(20)*yrot(90), mb_capsule(d=21, h=36, influence=0.5), // body
    right(21)*up(25)*yrot(-20), mb_capsule(r=7, h=25, influence=0.5, cutoff=9), // head
    right(24)*up(10)*yrot(15), mb_cyl(d1=3, d2=6, h=15, cutoff=3), // trunk
    // ears
    right(18)*up(29)*fwd(11)*zrot(-20)*yrot(80)*scale([1.4,1,1]), mb_disk(r=5,h=2, cutoff=3),
    right(18)*up(29)*back(11)*zrot(20)*yrot(80)*scale([1.4,1,1]), mb_disk(r=5,h=2, cutoff=3),
    // tusks
    right(26)*up(13)*fwd(5)*yrot(135), mb_capsule(r=1, h=10, cutoff=1),
    right(26)*up(13)*back(5)*yrot(135), mb_capsule(r=1, h=10, cutoff=1)
];
bbox = [[-21,-17,-9], [31,17,38]];
metaballs(spec, bounding_box=bbox, voxel_size=vsize, isovalue=isoval, 
    debug=debug, show_box=box, show_stats=stats)
        fwd(55) color("gold") vnf_polyhedron($metaball_vnf);


        