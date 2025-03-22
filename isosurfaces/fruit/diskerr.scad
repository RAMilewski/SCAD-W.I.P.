include<BOSL2/std.scad>
include<BOSL2/isosurface.scad>

bbox = [[-10,-10,-10],[10,10,10]];

spec = [
   IDENT, mb_disk(h = 2, d = 10),
];

metaballs(spec, bbox);