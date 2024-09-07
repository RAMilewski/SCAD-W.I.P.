include <BOSL2/std.scad>

$fn = 72;

od1 = 45;
od2 = 20;
washer = [39, undef, 1.25];
spacer = [35.5, undef, 1.25];
id = 11;
h = 4;

spacer();

module top() {
    diff() {
        cyl(h = h/2, d = od1, rounding1 = 1, rounding2 = 0.75)
            attach(TOP) cyl(h = h/2, d1 = od1-1, d2 = od2, texture = "wave_ribs")
                attach(TOP) cyl(h = h/2, d = od2, rounding2 = 1);
            tag("remove") cyl(h = 3* h, d = id);
    }
}

module bot() {
    diff(){
        cyl(h = 2 * washer.z, d = washer.x + 4, rounding = 1)
           position(TOP) tag("remove") cyl(h = washer.z, d = washer.x, rounding2 = -1, anchor = TOP);
            tag("remove") cyl(h = h, d = id);

    }
}

module spacer() {
    diff(){
        cyl(h = spacer.z, d = spacer.x)
            tag("remove") cyl(h = h, d = id);

    }
}