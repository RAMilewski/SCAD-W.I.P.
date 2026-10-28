
include<BOSL2/std.scad>
include <BOSL2/screws.scad>


$fe = 5;

r1 = 36;
r2 = 4;
offset = 0.1;

wall = 2;
h = 20;
handle=[20,40,h];

outer = hull_region([circle(r1+wall), right(r1+wall+offset, circle(r2))]);
inner = hull_region([circle(r1), right(r1+offset, circle(r2))]);
reg = difference(outer, inner);

diff() {
    linear_sweep(reg,h) {
        fwd(r1) cuboid([h,h/2,h], rounding = h/4, except = BACK, anchor = BACK)
            position(LEFT) #screw_hole("M3,15",head="socket",counterbore=5,
                anchor=TOP, orient = LEFT);
        fwd(r1-0.1) tag("remove") cuboid([3,h+1,h], anchor = BACK);
        back(r1) cuboid(handle, rounding = handle.x/2, 
             except = [TOP,BOT,FWD], anchor = FWD);
       
    }
}