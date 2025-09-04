include<BOSL2/std.scad>

$text = "Text";

$fn = 72;




//label(0.2); 
 block();

module label(H) {
    xscale(-1) text3d($text, font = "Impact", h = H, size = 14, center = true ); 
}

module block() {
    diff() {
        cuboid([50,30,5], rounding = 2, anchor = BOT);
        tag("remove") label(0.201);
    }
}