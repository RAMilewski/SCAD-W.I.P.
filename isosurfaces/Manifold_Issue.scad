include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

v_size = 0.52;
bbox = [[-16,-17,25], [-1,7,35]];

front_leg = metaballs([ 
    move([-9,-4,30]) * zrot(30) * scale([1.5,5,1.75]), mb_sphere(3),
    move([-9,10,30]), mb_sphere(2, negative = true),
], bbox, v_size, show_stats = true);

vnf_polyhedron(front_leg)
    position(FWD) cube(1);
