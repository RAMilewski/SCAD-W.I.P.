include<BOSL2/std.scad>
include<RD09(meshmixer).ASCII.scad>

$fn = 64;

cavity = [29, 17, 8];
wall = 1.5;
walls = 2 * [wall, wall, wall];
body = cavity + walls;
echo(body);

*color("gray") object1();
*down(0) back(0) right(10) xrot(90) zrot(90) ruler();

fwd (15) bottom_half() shell();
back(15) top();


module top() {
    xrot(180) top_half() shell();
        ycopies(n=2, spacing = cavity.y - wall/2) right(cavity.x/2+0.5) {
            cuboid([cavity.x, wall/2, cavity.z], rounding = 2*wall, edges = "Y", except = BOT)
                position(TOP) xcyl(l = cavity.x - 3 * wall, d = wall, rounding = wall/2, anchor = TOP);
        }
}



module shell() {
    tag_scope()
    diff() {
        right(15) cuboid(body, rounding = 2){
            position(BOT) up(wall) tag("remove") cuboid(cavity, anchor = BOT+CENTER);
            position(LEFT) right(wall/2) tag("remove") antenna_hole(wall + 0.1);
            position(RIGHT) left(wall/2) up(1) tag("remove") usb_hole(wall + 0.1);
            up(body.z/2 - 0.25) tag("remove")
                text3d("RD09", font = "Arial Black", size = cavity.y/3, h = 0.5, center = true, atype = "ycenter");
        }
    }
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