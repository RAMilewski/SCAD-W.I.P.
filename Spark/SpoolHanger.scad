include<BOSL2/std.scad>
include<BOSL2/screws.scad>


$fn = 72;

cuboid([160,30,15], rounding = 15, edges = "Z", except = RIGHT){
    position(TOP+LEFT) right(15) cyl(h = 100, d = 20, rounding1 = -5, rounding2 = -5, anchor = BOT)        //post
        position(TOP) cyl(h = 3, d = 30, rounding2 = 1, anchor = BOT);
    diff(){
        position(RIGHT+BOT) cuboid([10,70,15], anchor = LEFT+BOT, rounding = 7.5, edges = "X")
            tag("remove") ycopies(l = 50) position(LEFT) yrot(-90) #screw_hole("#6,1/2",head="flat",counterbore=0, anchor = TOP);
    }


}