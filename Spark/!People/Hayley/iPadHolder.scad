include<BOSL2/std.scad>

cuboid([254,169,5], rounding = 20, edges = "Z", except = FWD, anchor = BOT){
    position(FWD+BOT) cuboid([254,5,23], anchor = BOT){
        xcopies(n = 2, spacing = 108) #ycyl(h = 10, d = 7);
        position(TOP+FWD) cuboid([254,23,5], rounding = 20, edges = "Z", except = FWD, anchor = BOT+FWD);
    }
}
