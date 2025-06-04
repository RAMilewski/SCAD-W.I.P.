include<BOSL2/std.scad>

$fn = 144;
id = 107;

tube(id = id, wall = 6, h = 2 , anchor = BOT){
    position(TOP)tube(id = id, wall = 2, h = 24, anchor = BOT) {
        position(TOP) tube(id1 = id, id2 = id-6, wall = 2, h = 35, anchor = BOT);
    }
}