include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

frames = 100;
span = 30;
/*position = $t <= 0.5 ? 
    [0, 0 , span/2 - $t * 2 * span] : 
    [0, 0, -span/2 + ($t -0.5) * $t * 2 * span];
*/
position = [0,0,3];

bounding_box = [[-25, -25, 0], [25, 25, 10]];
isovalue = 1;
voxel_size = 0.6;


funcs = [
    scale([4,4,0.2]) * up(5), mb_roundcube(10),
    move(position), mb_sphere(1),  
];

*metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = true);
echo (position);

path1 = ellipse([5,15], zrot(45));
stroke(path1);
path2 = ellipse([14,6]);
stroke(path2);
path3 = ellipse([20,2]);
stroke(path3);