include <BOSL2/std.scad>
$fn = 144;

    shell();
    disc();
    up(13) disc();


module shell() {
    back_half(s = 250)
    tube(id = 201, wall = 2, h = 15, circum = true, anchor = BOT);
}

module disc() {
    diff() {
       back_half(s = 250, y = -30)
        cyl(d = 203, h = 2, circum = true, anchor = BOT) {
            for (r = [10:15:90]) {
                *tag("remove") back(8) arc_copies(n = r/5, r = r, sa = 0, ea = 180) cyl(d = 10, h = 2.1);
            }
        }
    }
}