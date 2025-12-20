include<BOSL2/std.scad>

dia = 175;
lift = 25;

diff(){
    tube(od = dia/5, wall = 4, h = lift){
        zrot_copies(n = 3, sa = 60) position(BOT) tag("remove") #cuboid([dia/8,5,lift/4], anchor = LEFT+BOT);
        zrot_copies(n = 3) position(BOT) right(dia/10-1)    
            cuboid([dia/2 - dia/10, 5, lift], rounding = lift/3, edges = "Y", except = LEFT, anchor = LEFT+BOT);
    }
}