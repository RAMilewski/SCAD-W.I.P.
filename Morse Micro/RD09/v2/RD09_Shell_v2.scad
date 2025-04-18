include<BOSL2/std.scad>
include<RD09(MeshLab).scad>

font = "Phosphate:style=solid";  // ["Phosphate:style=solid","Righteous","Arial Black","Impact"]
label_fill = false;
text_height = 0.2;

/* [Hidden] */
$fn = 64;
cavity = [27, 17, 7];
wall = 1.5;
walls = 2 * [wall, wall, wall];
body = cavity + walls;

/*
color("red") down (0.25) object1();  // from RD09(MeshLab).scad

bottom_half() ghost() shell();
*left(8) fwd(50) rot([90,0,90]) ruler();

/* */

if (label_fill) {
    down(body.z/2 - text_height/2) label();
} else {
    fwd (15) bottom_half() shell();
    back(15) top();
}

/* */


module top() {
    xrot(180) top_half() shell();
        ycopies(n=2, spacing = cavity.y - wall/2) right(cavity.x/2+0.5) {
            cuboid([cavity.x, wall/1.5, cavity.z], rounding = 2*wall, edges = "Y", except = BOT)
                position(TOP) xcyl(l = cavity.x - 3 * wall, d = wall, rounding = wall/2, anchor = TOP);
        }
}



module shell() {
    tag_scope()
    diff() {
        right(15) cuboid(body, chamfer = 2){
            position(BOT) up(wall) tag("remove") cuboid(cavity, anchor = BOT+CENTER);
            position(LEFT) move([wall/2, -0.3, 0]) tag("remove") antenna_hole(wall + 0.1);
            position(RIGHT) left(wall/2) up(.75) tag("remove") usb_hole(wall + 0.1);
            zcopies(n = 2, spacing = body.z - text_height/2)  xrot(180 * $idx) xscale(-1) tag("remove")
                color("skyblue") text3d("RD09", font = font, size = cavity.y/2.5, h = text_height, center = true, atype = "ycenter");        
        }
    }
}

module label() {
    ycopies(n = 2, spacing = 30) right(cavity.x/2 + 0.5) xscale(-1) //zrot($idx * 180)
    color("red") text3d("RD09", font = font, size = cavity.y/2.5, h = text_height, center = true, atype = "ycenter");

}

module usb_hole(len) {
    usb_dim = [len, 12, 4.75];
    usb_r = 0.5; //corner radius
    cuboid(usb_dim, rounding = usb_r, edges = "X");
}

module antenna_hole(len){
    or = 3.5;
    flat = 0.5;
        tag_scope() 
        diff() {
            xcyl(h = len, r = or) {
                position(TOP) tag("remove") cuboid([len, 2 * or, flat], anchor = TOP);
                position(BOT) tag("remove") cuboid([len, 2 * or, flat], anchor = BOT);
        
        }
    }
}


/* */