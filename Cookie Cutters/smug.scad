include <BOSL2/std.scad>

render = "all";  // [frame, stamp, all]


/* [Hidden] */
$fn = 36;
eps = 0.1;
taper = 1.5;
font_size = 10;
kern = font_size * 1.1;
font = "Gill Sans";
depth = 4;
apple_z = depth/2;
dough = 15;

cookie = [50,50];
corner = 6;

base = cookie + [5,5];
base_wall = 5;
base_h = 1.5;
cutter = [52.5,52.5];
cutter_wall = 0.5;
cutter_h = depth;


if (render == "frame") frame();
if (render == "stamp") stamp();
if (render == "all") {frame(); right(cookie.x+10) stamp();}


module frame(){
    rect_tube(size = base, wall = base_wall, h = base_h, rounding = corner, irounding = corner, anchor = BOT)
    attach(TOP)
        rect_tube(size = cutter, wall = 0.5, h = dough, rounding = corner, irounding = corner, anchor = BOT);
}


module stamp() {
    xscale(-1) {  // flip horizontal
        cuboid([cookie.x, cookie.y, 1], rounding = corner, edges = "Z", anchor = BOT ) {
        left(font_size*1.6) fwd(13) attach(TOP) SMUG();
        attach(TOP) apple();
        }
    }
}

module apple() {
    difference() {    
        minkowski() {
            down(depth/2) back(8) scale([0.6,0.6,]) import("apple.stl");
            cyl(d1 = taper, d2 = 0, h = depth);
        }
        cuboid([50,50,10], anchor = TOP);
    }
}



module SMUG() {
    left (font_size * 0.05)
    taperText("S",font_size);
    right(font_size)
    taperText("M",font_size);
    right(kern + font_size)
    taperText("U",font_size);
    right(2* kern + font_size)
    taperText("G",font_size);
}


module taperText(char,font_size) {
    difference() {
        minkowski() {
            text3d(text = char, size = font_size, font = font, h = depth, center = true);
            cyl(d1 = taper, d2 = 0, h = depth);
        }
    cuboid(font_size * 2, anchor = TOP);
    }
}