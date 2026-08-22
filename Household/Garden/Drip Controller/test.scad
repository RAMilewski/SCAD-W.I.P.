include<BOSL2/std.scad>

difference() {
    cube(30);
    translate([-.01,-.01,5]){
        cube(10);
        translate([0,0,10]) cube(10);
    }
}