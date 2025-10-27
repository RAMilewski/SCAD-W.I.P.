    include <BOSL2/std.scad>
    include <BOSL2/hooks.scad>

    $fn = 72;
   
    left(35)
    ring_hook(base_size = [60,20], hole_z = 10, hole = rect([30,10], rounding = [4,4,0,0]), od = 60, rounding = 3, hole_rounding = 5, fillet = 5, outside_segments = 72);
    right(35)
    ring_hook(base_size = [60,20], hole_z = 20, hole = rect([30,10], rounding = [4,4,0,0]), od = 60, rounding = 3, hole_rounding = 5, fillet = 5, outside_segments = 72);

