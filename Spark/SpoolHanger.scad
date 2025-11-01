include<BOSL2/std.scad>
include<BOSL2/screws.scad>


$fn = 72;

cuboid([160,30,15], rounding = 15, edges = "Z", except = RIGHT) { //arm
    position(TOP+LEFT) right(15) cyl(h = 100, d = 20, rounding1 = -5, anchor = BOT)  //post
        position(TOP) cyl(h = 9, d = 30, rounding1 = 7.5, teardrop = true, rounding2 = 1, anchor = BOT);
    diff(){
        position(RIGHT+BOT) cuboid([10,70,25], anchor = LEFT+BOT, rounding = 7.5, edges = "X")
            tag("remove") ycopies(l = 50) position(LEFT) yrot(-90) #screw_hole("#6,1/2",head="flat",counterbore=0, anchor = TOP);
    }


}