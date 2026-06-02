include <BOSL2/std.scad>

$fn = 72;


module base_cutout (repeat = [2,2], unit = 24, spacing = 52, depth = 2.5, groove = 1.5, r = 5.5, anchor = CENTER, spin = 0, orient = UP)
    grid_copies(n = repeat, spacing = spacing) 
        rect_tube(size = 24, h = depth, wall = groove, rounding = r) {
            //color("skyblue") text(str($col,",",$row), anchor = CENTER);  // Label boxes
            if (repeat.x > 1) { 
                position(RIGHT) if ($col < repeat.x - 1) {ycopies(n = 2, spacing = 11) cuboid([spacing-unit,groove,depth], anchor = LEFT);}
            }
            if (repeat.y > 1) {
                position(FWD)   if ($row > 0) {xcopies(n = 2, spacing = 11) cuboid([groove,spacing-unit,depth], anchor = BACK);}
            }

        }

