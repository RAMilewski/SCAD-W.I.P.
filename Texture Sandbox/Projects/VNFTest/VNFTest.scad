include <BOSL2/std.scad>
include <20x20S.scad>

vnf =   heightfield(custom, size = [20,20], bottom = 1e-12, maxz = 1);
vnf_validate(vnf);

*heightfield(custom, size = [20,20], bottom = -1e-12, maxz = 1, style = "alt");