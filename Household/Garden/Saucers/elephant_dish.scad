include<BOSL2/std.scad>
$fn = 72;

 core(); 

module dish() {
    diff() {
        cyl(d = 165, h = 4, anchor = BOT)
            position(BOT) tube(od1 = 169, od2 = 190, h = 20, wall = 4, rounding2 = 2, anchor = BOT); 
            tag("remove") cyl(d = 20, h = 4, circum = true,rounding2 = -3, anchor = BOT);
    }
}

module core() {
    diff() {
        cyl(d = 19.5, h = 30, rounding1 = -3, anchor = BOT)
            tag("remove") position(TOP) cyl(d = 4, h = 25, rounding2 = -2, anchor = TOP);
    }
}