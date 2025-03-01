include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

h1  = 10;
r1 = 25;
r2 = 5;
d1 = r1 * 2;

isovalue = 1;
voxel_size = 0.5;

infl = 0.2;
cut  = 10;
N=7;
metaballs([
    IDENT, mb_disk(h1,r1),
    up(r1-2),  mb_sphere(r1*4, influence = 1,  negative = true, cutoff = r1+2),
    for(M=zrot_copies(n=N))
      each [M*right(r1),   mb_sphere(r2, influence = infl, negative = true, cutoff = cut)]
    ]
  ,[[-r1,-r1,-h1/2], [r1,r1,h1/2]], voxel_size, show_stats = true);
