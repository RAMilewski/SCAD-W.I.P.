include <BOSL2/std.scad>
include <BOSL2/bottlecaps.scad>

$fn = 72;

od = 11;
id = 7;
extension = 40;
bend = 30;
vent = 2;
cap_h = 26.5;
fillet = 5;

path = arc(r = 20, angle = 50, n = 24);
region = make_region([circle(d = od), circle(d = id)]);

//back_half(s= 200)
diff() {
    pco1810_cap(texture = "ribbed", orient = DOWN, anchor = TOP) {
        tag("remove") position(BOT) right(od - 1) cyl(d = vent, h = 20);
        tag("remove") position(BOT) up(3.1) cyl(d = id, h = cap_h, anchor = CENTER);
        position("inside-top") cyl(d = od, h = 14.1, rounding1 = -fillet, anchor = BOT);
        position(BOT) cyl(d = od, h = 10, rounding2 = -fillet * 2, anchor = TOP)
            position(BOT) tube(od = od, id = id, h = extension - 10, anchor = TOP)
                position(BOT) path_sweep(region,path, anchor = "start-centroid", orient = BACK);
    }
}

