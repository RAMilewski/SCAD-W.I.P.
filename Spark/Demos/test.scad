include <BOSL2/std.scad>
$fn = 64;
vnf0 = cyl(d = 100, h = 1, center=true);
vnf1 = up(20, p=vnf0);
bent1 = vnf_bend(vnf1, axis="Y");
zscale(1.5) vnf_polyhedron(bent1);