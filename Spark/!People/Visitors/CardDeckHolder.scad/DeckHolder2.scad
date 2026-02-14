include<BOSL2/std.scad>


$fn = 72;
card = [63,88,0.2];
wall = 2;
depth = 25;
size = [card.x + 2 * wall + 1, card.y + wall , wall];


//base(); up(2*wall) #card(); up(depth/2) color("lightblue") lid();

base(); right(size.x +10) lid(); 

module card() { cuboid(card, rounding = 4, edges = "Z"); }

module base() {
    cuboid(size, rounding = 5, edges = "Z"){
        diff() {
            position(TOP) rect_tube(size = [size.x, size.y], h = depth, wall = wall, rounding = 5);
            position(TOP+FWD) tag("remove") 
                cuboid([card.x+1,wall*4,depth], anchor = BOT);
        }
    }
}



module lid() {
    diff() {
        cuboid([size.x - 2.5 * wall, size.y - 2.5 * wall, wall], rounding = 5, edges = "Z")
            tag("remove") position(FWD) fwd(1) 
                prismoid(size1 = [20,50], size2 = [20,50], h = wall, 
                rounding = [10,10,0,0], anchor = FWD);
    }
}