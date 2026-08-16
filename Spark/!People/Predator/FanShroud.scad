include <BOSL2/std.scad>
include <BOSL2/turtle3d.scad>


$fn = 72;
i_port = [15.75,19.75];
wall   = [4,4];
o_port = i_port + wall;


rgn = [
    rect(o_port, rounding = 1),
    rect(i_port)];
 
slot = [3,13,1.1];   
    
path = turtle3d(["move",18.76,"arcright",8,90,"move",9]);

diff() {
    path_sweep(rgn, path)
        position(BOT+FWD) left(o_port.x/2 -1) up(wall.y/2)
            tag("remove") cuboid(slot, anchor = TOP+FWD);
}


ruler();