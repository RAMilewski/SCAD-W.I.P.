include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = triangulate; // [true,false]

v_size = 0.52;

body = [
    up(20) * scale([1,1.2,2]), mb_sphere(10), 
    up(10), mb_sphere(5),   
    up(50) * scale([1.2,0.8,1]), mb_sphere(10, cutoff = 15),
    move([0,-11,50]), mb_cuboid(2),
    move([5,-10,54]), mb_sphere(0.5, negative = true),
    move([-5,-10,54]), mb_sphere(0.5, negative = true),
    move([0,15,6]), mb_sphere(2, cutoff = 5),
];


hind_leg = metaballs([ 
    move([-15,-5,3]) * scale([1.5,4,1.75]), mb_sphere(5),
    move([-15,10,3]), mb_sphere(3, negative = true),
], [[-22,-24,0], [-8,7,11]], v_size, show_stats = stats);

front_leg = metaballs([ 
    move([-9,-4,30]) * zrot(30) * scale([1.5,5,1.75]), mb_sphere(3),
    move([-9,10,30]), mb_sphere(2, negative = true),
], [[-16,-17,25], [-1,7,35]], v_size, show_stats = stats);
//[[-16,-17,25], [-1,7,35]]
ear = metaballs([
    yrot(10) * move([0,0,65]) * scale([4,1,7]) , mb_sphere(2),
    yrot(10) * move([0,-3,65]) * scale([3,2,6]) , mb_sphere(2, cutoff = 2, influence =2, negative = true),
],  [[3,-2,50], [20,2,78]], v_size, show_stats = stats);

color_this("BurlyWood") {
    metaballs(body,[[-16,-17,0], [16,20,63]], v_size, show_stats = stats);
    xflip_copy() {
        vnf_polyhedron(hind_leg);
        vnf_polyhedron(front_leg);
        vnf_polyhedron(ear);
        move([5,-8,54]) recolor("skyblue") sphere(2, $fn = 32); //eyes
        move([1.1,-10,44]) recolor("white") cuboid([2,0.5,4], rounding = 0.15); //teeth
    }
}
 


