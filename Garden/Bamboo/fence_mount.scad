include<BOSL2/std.scad>

mast_dia = 25;
wall = 3;
h = 20;
tab = 30;
diff(){
    tube(l = h, id = mast_dia, od = mast_dia + 2*wall, anchor = BOT){
        position(BACK) fwd(wall/2) right(tab/2) 
            cuboid([tab,wall,h], rounding = h/3, teardrop = true, edges = [RIGHT+TOP,RIGHT+BOT]);
        position(BACK) fwd(wall*2) right(mast_dia/2)
            cuboid([tab-mast_dia/2,wall,h], rounding = h/3, teardrop = true, edges = [RIGHT+TOP,RIGHT+BOT], anchor = LEFT);
        position(BACK) fwd(wall) tag("remove") cuboid([20,wall/2,h], anchor = LEFT+BACK);
        tag("remove") cuboid([mast_dia/2,mast_dia/2,h], anchor = LEFT+FWD);
        right(mast_dia/2) cuboid([wall,10,h], anchor = LEFT+FWD);
         right(tab * .75) back(mast_dia/2) tag("remove") #ycyl(h = 10, d = 5);
    }
}