include<BOSL2/std.scad>
    
    
d1 = 72;
d2 = 10;
offset = 2;
wall = 2;
h = 10;


zscale(10) difference() {
    hull() circle((d1+wall)/2) position(RIGHT) right(offset) circle(d2/2);
    hull() circle(d1/2) position(RIGHT) right(offset) circle(d2/2);
}