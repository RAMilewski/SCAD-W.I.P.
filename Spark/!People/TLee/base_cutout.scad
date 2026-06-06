include <BOSL2/std.scad>


footprint = [2,3];

module base_cutout (size = footprint, unit = 24, spacing = 52, depth = 2.5, groove = 2.25, r = 5.5, anchor = CENTER, spin = 0, orient = UP, $fn = 72) 
    grid_copies(n = size+[1,1], spacing = spacing) 
        rect_tube(size = 24, h = depth, wall = groove, rounding = r) {
            position(RIGHT) if ($col < size.x) {ycopies(n = 2, spacing = 11) cuboid([spacing-unit,groove,depth], anchor = LEFT);}
            position(FWD)   if ($row > 0) {xcopies(n = 2, spacing = 11) cuboid([groove,spacing-unit,depth], anchor = BACK);}
        }


