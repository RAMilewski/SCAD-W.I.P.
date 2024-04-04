include <BOSL2/std.scad>
$fn = 72;
d = 16.3;
h = 16.3;

diff()
    cyl(d = d, h= h, rounding = 1, anchor = BOT){
      position(TOP)  
        tag("remove") cyl(d = 6, h = 3, anchor = TOP, $fn = 6);
        tag("remove") cyl(d = 3.7, h = 26, $fn = 32); 
    }