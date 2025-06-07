include<BOSL2/std.scad>

$fn = 144;
id = 107;

tube(id = id, wall = 6, h = 2 , anchor = BOT){
    position(TOP)tube(id = id, wall = 1, h = 20, anchor = BOT) {
        position(TOP) tube(id1 = id, id2 = id-12, wall = 1, h = 25, anchor = BOT);
    }
}