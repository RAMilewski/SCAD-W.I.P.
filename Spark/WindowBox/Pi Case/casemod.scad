include<BOSL2/std.scad>


bottom();



module top(){
    up(3.5) yrot(180) import("top.stl");
    left(3.5) back(33) #cuboid([6,54,1], anchor = BOT);
}

module bottom(){
    up(0.5)import("bottom.stl");
    
}