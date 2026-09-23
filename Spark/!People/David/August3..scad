include<BOSL2/std.scad>
    
zscale(20) difference() {
    hull() circle(50) position(RIGHT) circle(10);
    hull() circle(45) position(RIGHT) circle(10);
}