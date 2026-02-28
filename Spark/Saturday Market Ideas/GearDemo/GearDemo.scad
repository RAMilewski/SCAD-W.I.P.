include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 144;
mod = 2;
teeth = 50;
thickness = 8;
shaft_diam = 5;
backing = 10;
spread = 150;

right(spread) spur_gear(mod=mod, teeth=teeth/2, thickness=thickness, shaft_diam=shaft_diam)
    position(TOP) back(mod*teeth/8) yscale(2) zrot(-30)  #cyl(d = 8, h = 1, anchor = BOT, $fn = 3);


spur_gear(mod=mod, teeth=teeth, thickness=thickness, shaft_diam=shaft_diam)
    zrot(3.6) position(TOP) back(mod*teeth/3) yscale(2) zrot(-30)  #cyl(d = 8, h = 1, anchor = BOT, $fn = 3);

diff() {
    right(spread) ring_gear(mod = mod, teeth=teeth, thickness=thickness, backing=backing)
        zrot_copies(n=4, r = mod*teeth/2 + backing*.75) tag("remove") #cyl(d = shaft_diam, h = thickness);
}

right(spread*0.45) zrot(90) down(thickness/2)
    diff(){
        rack(mod=mod, teeth=teeth, thickness=thickness, bottom = thickness * 1.5, anchor = BOT)
            down(thickness) xcopies(n = 2, spacing = 2* mod * teeth) tag("remove") #ycyl(h = thickness, d = shaft_diam);
}