include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

frames = 100;
span = 30;
position = $t <= 0.5 ? 
    [-span/2 + $t * 2 * span, 0 , span/2 - $t * 2 * span] : 
    [span/2 - ($t - 0.5) * $t * 2 * span, 0, -span/2 + ($t -0.5) * $t * 2 * span];

bounding_box = [[-20, -10, -20], [20, 10, 20]];
isovalue = 1;
voxel_size = 0.6;

funcs = [
    IDENT, mb_sphere(5),
    move(position), mb_sphere(3),  
];

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = true);
echo (position);

//for (i = [0:.01:1]) { echo(i, i * 2 * frames/(frames/span)); }