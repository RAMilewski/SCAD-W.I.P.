include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 144;
mod = 1;
teeth = 90;
thickness = 4;
shaft_diam = 4;
backing = 10;
spread = 120;

right(100) spur_gear(mod=mod, teeth=teeth/2, thickness=thickness, shaft_diam=shaft_diam)
    position(TOP) back(mod*teeth/8) yscale(2) zrot(-30)  #cyl(d = 8, h = 1, anchor = BOT, $fn = 3);

right(145) spur_gear(mod=mod, teeth=teeth/3, thickness=thickness, shaft_diam=shaft_diam)
    position(TOP) back(mod*teeth/12) yscale(2) zrot(-30)  #cyl(d = 6, h = 1, anchor = BOT, $fn = 3);

spur_gear(mod=mod, teeth=teeth, thickness=thickness, shaft_diam=shaft_diam)
    zrot(3.6) position(TOP) back(mod*teeth/3) yscale(2) zrot(-30)  #cyl(d = 8, h = 1, anchor = BOT, $fn = 3);

diff() {
    right(spread) ring_gear(mod = mod, teeth=teeth, thickness=thickness, backing=backing){
        zrot_copies(n=4, r = mod*teeth/2 + backing*.75, sa = 45) tag("remove") #cyl(d = shaft_diam, h = thickness);
        position(TOP) back(mod*teeth/2 + backing/2 + 2) yscale(1.8) zrot(-210)  #cyl(d = 6, h = 1, anchor = BOT, $fn = 3);
    }
}

right(spread*0.45) zrot(90) down(thickness/2)
    diff(){
        rack(mod=mod, teeth=teeth, thickness=thickness, bottom = thickness * 2.5, anchor = BOT)
            down(thickness * 1.5) xcopies(n = 2, spacing = 2* mod * teeth) tag("remove") #ycyl(h = thickness, d = shaft_diam);
}