include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

//right(60) down(5)
// bottom_half() fwd(5) xrot(-90) zrot(360/16)  import("OSmakercoin.stl");

$fn = 144;


r1 = 25; // Major radius of the coin
r2= 5;  // radius of the edge
n = 4;   //bezier segments to complete circle
d = r2 * (4/3) * tan(180/(2*n)); //control point distance


bez = flatten([
    bez_begin([-r1 + r2, r2], RIGHT, 2),
    bez_tang ([0, 1], RIGHT, 9),
    bez_end([r1 - r2, r2], LEFT, 2),
]);


path = [
    xcopies(40) circle(r2),
    fwd(r2/2) rect([2*(r1-r2), r2]),
    bezier_curve(bez)
];

stroke(path);

/*

back_half() 
 diff() {
    torus(d_min = 10, od = 50){
        up(3) cyl(h = 8, d = 40, anchor = TOP);
        tag("remove") position(TOP) zscale(0.9) up(29) spheroid(d = 70);
    }
 }

 */