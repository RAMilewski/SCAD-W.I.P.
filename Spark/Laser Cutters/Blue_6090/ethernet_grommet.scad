include<BOSL2/std.scad>

$fn = 32;
hole = [16,18];
face = hole + [10,10];

    diff(){
        cuboid([face.x,face.y,2], rounding = 2, edges = "Z", anchor = BOT) {
            position(TOP) cuboid([hole.x,hole.y,5], rounding = 0.5, edges = "Z", anchor = BOT);
            tag("remove") down(1) #cuboid([hole.x-1, hole.y-1, 10], anchor = BOT);
            

    }
}
