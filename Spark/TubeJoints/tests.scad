include<BOSL2/std.scad>

large_plug();

module large_plug2() {
    diff() {
        cuboid([14,25,2], rounding = 5, edges = "Z", anchor = BOT)
            attach(TOP,BOT) cuboid([10,21,30], rounding = 5, edges = "Z", anchor = BOT);
            tag("remove") up(12) xcyl(d = 5.5, h = 11);
    }
}

module large_plug() {
    $fn = 72;
    diff() {
        cuboid([13,24,2], rounding = 6.5, edges = "Z", anchor = BOT)
            attach(TOP,BOT) prismoid([10,21],[9,19], h = 25, 
                rounding1 = 5, rounding2 = 4.5, anchor = BOT);
        tag("remove") up(12) xcyl(d = 5.5, h = 11);
    }
}
