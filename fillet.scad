include<BOSL2/std.scad>
$fn = 36;

minkowski(){
    cylinder(d = 30, h = 40);
    difference() {
    translate([15,-5,0]) cube(5);
    translate([20,0,5]) sphere(d = 10);
    }
}