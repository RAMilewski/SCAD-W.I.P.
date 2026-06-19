/* 
    Bin Generator for Sortimo T-Boxx 320. 
    Version 1.1
    Copyright © 2026 By Richard A. Milewski
    All Rights Reserved
    Released under the BSD 2-Clause License
    https://opensource.org/license/bsd-2-clause
*/

include<BOSL2/std.scad>


/* [Footprint (x,y)] */
footprint  = [1,1];  // Footprint

/* [Dividers] */
dividers = [0,0] ;
// (% of bin height)
divider_height = 100;  //[5:5:100]

/* [Labels] */
label = true;
label_height = 10;   //[7:15]
label_text = "";
text_size = 8;     //[3:0.5:15]

/* [Hidden] */
taper = 2.5;
base  = 49.25;
top   = base + taper;
wall  = 1.5;
walls = 2 * wall;
floor = 4;
height = 63.5;


//left_half(s=400) 
sortimo_bin(footprint,dividers);


module sortimo_bin(footprint, dividers = dividers, anchor = BOT, spin = 0, orient = UP) {
       echo(footprint, dividers);
    rect0 = rect([top * footprint.x - taper - wall, top * footprint.y - taper - wall], chamfer = 7);   
    rect1 = rect([top * footprint.x - taper, top * footprint.y - taper], chamfer = 7); 
    rect2 = rect([top * footprint.x, top * footprint.y],  chamfer = 7);
    rect3 = rect([top * footprint.x - walls, top * footprint.y - walls], chamfer = 7);
    rect4 = rect([top * footprint.x - taper - walls, top * footprint.y - taper - walls], chamfer = 7);   
    attachable(anchor,spin,orient, size=[top * footprint.x, top * footprint.y, height]) {
        union() {
            diff(){
                position(BOT) skin([rect0,rect1,rect2,rect3,rect4], z = [0,floor,height,height,floor], slices = 10){
                    tag("remove") position(BOT) base_cutout(footprint, groove = 2.25);
                    dividers(footprint, dividers, height * divider_height/100);
                    if(label) position(TOP + BACK) down(1) fwd(wall) label_shelf(footprint, label_height);
                    grid_copies(n = footprint, spacing = top) tag("remove") position(BOT) cyl(h = 2, d1 = 28, d2 = 26);  
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

module dividers(footprint, count, height) {
    xcopies(n = count.x, spacing = base * footprint.x / (count.x+1))
        up(floor) prismoid(size1 = [wall, footprint.y * base - wall], size2=[wall, footprint.y * top - wall], h = height - floor, anchor = BOT);
    ycopies(n = count.y, spacing = base * footprint.y / (count.y+1))
        up(floor) prismoid(size1 = [footprint.x * base - wall, wall], size2=[footprint.x * top - wall, wall], h = height - floor, anchor = BOT);
}

module label_shelf(footprint, width) {
    prismoid(size1 = [top * footprint.x - walls - width,.1], size2 = [top * footprint.x,width], shift = [0,-width/2], h = width, chamfer1 = 0, chamfer2 = [7,7,0,0], anchor = TOP + BACK)
        position(TOP) color("blue") text3d(label_text, h = 0.6, size = text_size * 0.72, atype = "ycenter", anchor = CENTER+BOT);

}
