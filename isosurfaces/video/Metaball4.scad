include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

/*position = $t <= 0.5 ? 
    [0, 0 , span/2 - $t * 2 * span] : 
    [0, 0, -span/2 + ($t -0.5) * $t * 2 * span];
*/
path1 = resample_path(zrot(45,ellipse([5,15])),100);
path2 = resample_path(ellipse([14,6]),100);
path3 = resample_path(ellipse([20,2]),100);

stroke(path1, width = 0.1);

echo($t, 100 - 100* $t);

bounding_box = [[-25, -25, 0], [25, 25, 10]];
isovalue = 1;
voxel_size = 0.5;

retro = 99 - 99 * $t;
echo(len(path2));

funcs = [
    scale([5,5,0.2]) * up(5), mb_cuboid(11),
    move(path1[100 * $t]) * up(4), mb_sphere(2),
    move(path2[retro]), mb_sphere(2),
    move(path3[100 * $t]) * up(4), mb_sphere(2),  
];

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = true);
//echo (position);

