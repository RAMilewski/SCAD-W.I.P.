 include <BOSL2/std.scad>

$fn = 72;

base_dia = 125;
mid_dia = 135;
wall = 2;
h =  50;
margin = 5;

idia = base_dia + 2 * margin;
idia2 = idia * 1.15;
odia = idia + 2 * wall;
odia2 = idia2 + 2 * wall;

dish2();

module dish1() {  //straight sides
    cyl(d1 = idia, d2 = odia, h = wall, anchor = BOT) {
        zrot_copies(n = 6, d = idia/5) position(TOP) xcyl(d = wall, h = idia/3, rounding = wall/2, anchor = LEFT);
        position(BOT) tube(id1 = idia, od1 = odia, id2 = idia2, od2 = odia2, h = h, anchor = BOT)
            position(TOP) torus(d_min = wall, d_maj = odia2 - wall);
    }
}

module dish2() { //teardrop rounded sides
    import("Flower Pot Tray 1.stl");
}