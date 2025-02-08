include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

showpaths = true; //[true:false]


path1 = resample_path(zrot(45,ellipse([10,20])),100);
path2 = resample_path(zrot(180, ellipse([15,20])),100);
path3 = resample_path(ellipse([20,12]),100);

if (showpaths) { 
    up(3) {
        color("red") stroke(path1, width = 0.1, closed = true);
        color("blue") stroke(path2, width = 0.1, closed = true);
        color("green") stroke(path3, width = 0.1, closed = true);
    }
} 

echo($t, 100 - 100* $t);

bounding_box = [[-25, -25, 0], [25, 25, 10]];
isovalue = 1;
voxel_size = 0.5;



funcs = [
    //scale([5,5,0.2]) * up(5), mb_cuboid(11),
    move(path1[99 * $t]) * up(4), mb_sphere(2),
    move(path2[99 - 99*$t]) * up(4), mb_sphere(2),
    move(path3[99 * $t]) * up(4), mb_sphere(2),  
];

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = true);
//echo (position);

