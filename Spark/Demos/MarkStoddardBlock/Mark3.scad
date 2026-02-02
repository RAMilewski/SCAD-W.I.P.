include<BOSL2/std.scad>

module truncatedCube() {
difference() {
cube();
translate([1,0,0])
rot(from=[1,0,0],to=[1,-1,1])
translate([0,-1,0]) #cube(2);
}
}

module diagonalHalfCube() {
difference() {
cube();
rotate([45,0,0]) translate([-1,0,0]) cube(3);
}
}

truncatedCube();
/*
translate([0,1,1]) truncatedCube();
translate([0,1,0]) cube();
translate([1,1,0]) cube();
translate([1,0,0]) diagonalHalfCube();

/* */