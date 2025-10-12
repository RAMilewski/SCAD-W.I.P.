include <BOSL2/std.scad>

slot_y = 50;
slot_z = 25;
angle = 120;
ring_dia_in = 12.5;
ring_width_mm = 25;
ring_lift = 17;

dia = ring_dia_in * INCH;
$fn = 144;
shape = ring(d = dia, ring_width = -ring_width_mm, start = -angle/2, angle = angle);

diff() {
    right(ring_width_mm/2) linear_sweep(shape, slot_z + ring_lift, anchor = RIGHT+BOT);
    tag("remove") #cuboid([ring_width_mm *2, slot_y + 1, slot_z + 0.5], anchor = BOT);
}