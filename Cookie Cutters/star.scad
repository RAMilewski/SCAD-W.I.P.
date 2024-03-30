// Star shape cookie cutter

include <BOSL2/std.scad>

size = 40;
width = 1;
height = 12;
base = 3;
corner = 2;

blade = [offset(star(n = 5, od = size+width/2, id = size/2+width/2, align_tip = BACK),corner),
        offset(star(n = 5, od = size-width/2, id = size/2-width/2, align_tip = BACK),corner)];

blade_path = [up(0),up(height)];
sweep(blade,blade_path);

cap = [star(n = 5, od = size+width*2, id = size/2+width*2, align_tip = BACK),
        star(n = 5, od = size-width*2, id = size/2-width*2, align_tip = BACK)];

cap_path = [up(0), up(base)];
sweep(cap,cap_path);
