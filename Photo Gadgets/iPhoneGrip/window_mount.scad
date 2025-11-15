include<BOSL2/std.scad>

$fn = 72;

grip = [100,20,50];
gap = [101,4,38];
cyl = 6;

diff() {
    cuboid(grip, rounding = 3, except = BOT+FWD, teardrop = true){
        position(BOT+BACK) fwd(2) xrot(20) front_half(s = 200) cyl(l = 6, d = grip.x, rounding = 3, anchor = BOT)
            align(FWD) back(20) tag("remove") #cyl(l = 8, d = 8);
        position(BOT) up(grip.z - gap.z) tag("remove") xcyl(l = gap.x, d = 6)
             //tag("remove") cuboid(gap, rounding = -3, edges = TOP, anchor = BOT);
             tag("remove") prismoid([gap.x,4], [gap.x,1], h = gap.z);
        
    }
} 

