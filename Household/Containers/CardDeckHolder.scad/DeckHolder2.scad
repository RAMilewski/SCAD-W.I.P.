include<BOSL2/std.scad>


$fn = 72;
card = [63,88,0.2];
wall = 2;
depth = 25;
size = [card.x + 5, card.y + 5, wall];

cuboid(size, rounding = 5, edges = "Z"){
    diff() {
        position(TOP) rect_tube(size = [size.x, size.y], h = depth, wall = wall, rounding = 5);
        position(TOP+FWD) tag("remove") 
            #cuboid([card.x+1,wall*2,depth], anchor = FWD+BOT);
    }
}

right(80)

diff() {
    cuboid([size.x - 2.5 * wall, size.y - 2.5 * wall, wall], rounding = 5, edges = "Z")
        tag("remove") position(FWD) prismoid(size1 = [20,50], size2 = [22,52], h = wall, rounding = [10,10,0,0], anchor = FWD);
}