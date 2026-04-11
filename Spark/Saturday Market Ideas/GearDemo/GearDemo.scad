include <BOSL2/std.scad>
include <BOSL2/gears.scad>

$fn = 144;
mod = 1;
teeth = 90;
thickness = 5;
shaft_diam = 4.5;
backing = 15;
spread = 120;
arrow_shift = 180/teeth;
z_text = 0.5;
font = "Arial Black";    // [Arial Black, Lobster, Phosphate, Optima]

part = "gear90";  // [gear90, gear45, gear30, ring, rack, all]

if (part == "gear90") gear90(); 
if (part == "gear45") gear45(); 
if (part == "gear30") gear30();
if (part == "ring")   ring();
if (part == "rack")   rack1();   
if (part == "all") {
    left(65) gear90(); 
    right(65) back(10) { 
        ring();
        fwd(20)  gear45();
        back(25) gear30();
    }
    zrot(90) xrot(-90) rack1();
}   




module gear90() { 
    spur_gear(mod=mod, teeth=teeth, thickness=thickness, shaft_diam=shaft_diam){
        zrot(arrow_shift) position(TOP){
            back(mod*teeth/2.5 - 0.5) yscale(2) zrot(-30)  #cyl(d = 8,  h = z_text, anchor = BOT, $fn = 3);
            fwd(mod*teeth/5) #text3d("90", font = font,  h = z_text, size = 8, anchor = BOT);
        }
    }
}

module gear45() { 
    spur_gear(mod=mod, teeth=teeth/2, thickness=thickness, shaft_diam=shaft_diam){
        zrot(- arrow_shift/2 + 1) position(TOP){
            back(mod*teeth/5 - 3) yscale(2) zrot(-30)  #cyl(d = 6,  h = z_text, anchor = BOT, $fn = 3);
            fwd(mod*teeth/12) zrot(180) #text3d("45", font = font,  h = z_text, size = 5, anchor = BOT);
        }
    }
}

module gear30() { 
    spur_gear(mod=mod, teeth=teeth/3, thickness=thickness, shaft_diam=shaft_diam){
        zrot(-arrow_shift/2+ 1) position(TOP){
            back(mod*teeth/9) yscale(2) zrot(-30)  #cyl(d = 4,  h = z_text, anchor = BOT, $fn = 3);
            fwd(mod*teeth/18) zrot(180) #text3d("30", font = font,  h = z_text, size = 4, anchor = BOT);
        }
    }
}

module rack1() {
    diff(){
        rack(mod=mod, teeth=teeth, thickness=thickness, bottom = backing, anchor = BOT){
            position(FWD) down(thickness) rot([90,180,0]) tag("keep") #text3d("90", font = font,  h = z_text, size = 8, anchor = BOT);
            down(thickness + 4) xcopies(n = 2, spacing = 2* mod * teeth) tag("remove") ycyl(h = thickness, d = shaft_diam);
        }
    }
}

module ring() {
    diff() {
        ring_gear(mod = mod, teeth=teeth, thickness=thickness, backing=backing){
            zrot_copies(n=4, r = mod*teeth/2 + backing*.6, sa = 45) tag("remove") cyl(d = shaft_diam, h = thickness);
            position(TOP) back(mod*teeth/2 + backing/2 - 1) yscale(2) zrot(-210)  #cyl(d = 6,  h = z_text, anchor = BOT, $fn = 3);
            position(TOP)  fwd(mod*teeth/2 + backing/4) zrot(180) #text3d("90", font = font,  h = z_text, size = 8, anchor = BOT); 
        }
    }
}


/* */