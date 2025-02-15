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

function  tmat(ang) = move(cylindrical_to_xyz(r1,ang,0));  

metaballs([
    IDENT, mb_disk(h1,r1),
    up(r1-2),  mb_sphere(r1*4, influence = 1,  negative = true, cutoff = r1+2),
    tmat(0),   mb_sphere(r2, influence = infl, negative = true, cutoff = cut),
    tmat(45),  mb_sphere(r2, influence = infl, negative = true, cutoff = cut),
    tmat(90),  mb_sphere(r2, influence = infl, negative = true, cutoff = cut),
    tmat(135), mb_sphere(r2, influence = infl, negative = true, cutoff = cut),
    tmat(180), mb_sphere(r2, influence = infl, negative = true, cutoff = cut),
    tmat(225), mb_sphere(r2, influence = infl, negative = true, cutoff = cut),
    tmat(270), mb_sphere(r2, influence = infl, negative = true, cutoff = cut),
    tmat(315), mb_sphere(r2, influence = infl, negative = true, cutoff = cut),
], 
    voxel_size, [[-d1,-d1,-h1], [d1,d1,h1]], isovalue);






