include<BOSL2/std.scad>

$fn = 72;

 core(); dish();

module dish() {
    diff() {
        cyl(d = 100, h = 4, anchor = BOT)
            position(TOP) torus(d_maj = 95, d_min = 5); 
            tag("remove") cyl(d = 20, h = 4, circum = true,rounding2 = -3, anchor = BOT);
    }
}

module core() {
    diff() {
        cyl(d = 19.5, h = 25, rounding1 = -3, anchor = BOT)
            tag("remove") position(TOP) cyl(d = 4, h = 20, rounding2 = -2, anchor = TOP);
    }
}