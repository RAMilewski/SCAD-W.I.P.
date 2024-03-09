include <BOSL2/std.scad>
include <data3.scad>

vnf = heightfield(data, size = [10,10], bottom = 30, maxz = 33);
vnf_validate(vnf);

left(20)  heightfield(data, size = [10,10], bottom = 30, maxz = 33);
