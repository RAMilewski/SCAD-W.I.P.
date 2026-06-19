include <BOSL2/std.scad>
$fn = 72;

d = 130;
ribs = 5;


difference(){
    tube(od1 = d, od2 = 26, wall = 5, h = 60, anchor = BOT);
    difference(){ 
        tube(od1 = d, od2 = 26, wall = 5, h = 60, anchor = BOT);
        rot_copies(n = ribs) prismoid(size1 = [d,5], size2 = [d,1.5], h = 57, anchor = BOT);
    }
}
tube(od1 = d, od2 = 26, wall = 2, h = 60, anchor = BOT)
position(TOP) tube(od = 26, wall = 2, h = 35, anchor = BOT);