include<BOSL2/std.scad>


/* [Footprint (x,y)] */
ftpt  = [1,1];  // Footprint

/* [Dividers] */
dividers = [0,0] ;

/* [Hidden] */
taper = 2.5;
base  = 49.25;
top   = base + taper;
wall  = 1.5;
walls = 2 * wall;
floor = 4;
height = 63.5;


rect1 = rect([base * ftpt.x, base * ftpt.y], chamfer = 7);
rect2 = rect([top * ftpt.x, top * ftpt.y],  chamfer = 7);
rect3 = rect([top * ftpt.x - walls, top * ftpt.y - walls], chamfer = 7);
rect4 = rect([base * ftpt.x - walls, base * ftpt.y - walls], chamfer = 7);


        echo("before");
//right_half(s = 300) back_half(s = 200)
sortimo_bin(footprint = [1,1], dividers = [0,0]);


module sortimo_bin(anchor = BOT, spin = 0, orient = UP) {
    attachable(anchor,spin,orient, size=[top * ftpt.x, top * ftpt.y, height]) {
        union() {
            diff(){
                position(BOT) skin([rect1,rect1,rect2,rect3,rect4], z = [0,floor,height,height,floor], slices = 10){
                    tag("remove") position(BOT) base_cutout(ftpt, groove = 2.25);
                    dividers(dividers);
                    grid_copies(n = ftpt, spacing = base) tag("remove") position(BOT) cyl(h = 2, d1 = 28, d2 = 26);  
                }
            }
        }
        children();
    }
}

module base_cutout (size = footprint, unit = 24, spacing = 52, depth = 2.5, groove = 2.25, r = 5.5, anchor = CENTER, spin = 0, orient = UP, $fn = 72) 
    grid_copies(n = size+[1,1], spacing = spacing) 
        rect_tube(size = 24, h = depth, wall = groove, rounding = r) {
            position(RIGHT) if ($col < size.x) {ycopies(n = 2, spacing = 11) cuboid([spacing-unit,groove,depth], anchor = LEFT);}
            position(FWD)   if ($row > 0) {xcopies(n = 2, spacing = 11) cuboid([groove,spacing-unit,depth], anchor = BACK);}
        }

module dividers(count = [0,0]) {
    echo(count);
    xcopies(n = count.x, spacing = base * ftpt.x / (count.x+1))
        up(floor) #prismoid(size1 = [wall, ftpt.y * base - wall], size2=[wall, ftpt.y * top - wall], h = height - floor, anchor = BOT);
    ycopies(n = count.y, spacing = base * ftpt.y / (count.y+1))
        up(floor) #prismoid(size1 = [ftpt.x * base - wall, wall], size2=[ftpt.x * top - wall, wall], h = height - floor, anchor = BOT);
}
