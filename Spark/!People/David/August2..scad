include<BOSL2/std.scad>

r1 = 50;
r2 = 8;
wall = 4;
    
difference() {
    hull( circle(50) position(RIGHT) circle(10));
    hull() circle(45) position(RIGHT) circle(10);
}