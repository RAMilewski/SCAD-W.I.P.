include <BOSL2/std.scad>

$fn = 144;

cuboid([30, 30, 1.5]) {
    align(TOP,LEFT) cuboid([1.5, 30, 35], rounding = -5, edges = [RIGHT+BOT,RIGHT+TOP])
        align(TOP,LEFT) cuboid([30, 30, 1.5]) {
            attach(BOT,BOT) cyl(h = 5, d1 = 5, d2 = 0);
            attach(BOT,BOT) left(10) cyl(h = 8, d1 = 3, d2 = 0);
        }

    
}
