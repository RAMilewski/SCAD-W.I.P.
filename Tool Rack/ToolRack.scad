include <BOSL2/std.scad>

$fn = 64;
rounding = 0.5;
z_blank = 7.2;
triangle = 4.5;


module rail(width) {
    diff() {
        back(18) cuboid([20,2,width], anchor = RIGHT+BACK+BOT);
        tag("remove") back(17) left(15) up(width/2) ycyl(d = 3, h = 4, circum = true, $fn = 8);
        cuboid([12,18,width], rounding = 2, edges = "Z", anchor = FWD+BOT);
        tag("remove") back(4) right(1) scale([1.02,1.02]) blank(width, 6);
        
    }
}

module endcaps() {
    xflip_copy(x=10) {
        cuboid([12,18,1.5], rounding = 2, edges = "Z", anchor = FWD+BOT);
        back(4) right(1) #blank(3,5);
    }
}

module blank(width, length) {
    rgn = [
        rect([3,11], anchor = FWD+RIGHT, rounding = rounding),
        rect([length,z_blank], anchor = FWD+LEFT, rounding = [rounding,0,0,rounding]),
        right_triangle(triangle, anchor = FWD+LEFT),
    ];
    linear_sweep(make_region(rgn), width);
}


