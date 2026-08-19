include<BOSL2/std.scad>

$fn = 72;

rackgrid = [3.5, 29.62];

pin = [7.5, 7, 10];

pinX = 135.5;
pinY = [33.83, 81.78];

base = [200,100,3];

diff() {
    cuboid(base, rounding = 10, edges = "Z") {
        right(8) xcopies(n = 7, spacing = rackgrid[1])
            position(BOT) tag("remove") #ycyl(d = rackgrid[0], l = base.y);
            position(TOP) left(23) xcopies (n = 2, spacing = pinX)
                ycopies(n = 2, spacing = pinY[$idx])
                    cyl(h = pin.z, d1 = pin[0], d2 = pin[1], rounding1 = -pin[0]/3, rounding2 = pin[1]/2, anchor = BOT);
    }
}

//up(4)  ruler();