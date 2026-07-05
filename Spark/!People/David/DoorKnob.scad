include<BOSL2/std.scad>

$fn = 72;

width = 58;
r = 28;
wall = 4;

path = teardrop2d(r = r, ang = 35 );


//back_half(s=200)
diff()
    linear_sweep(path, width) fwd(wall) {
        attach(TOP,BOT) cyl(h = wall, r = r + wall);
        attach(BOT,TOP) cyl(h = wall, r = r + wall)
            position(BOT) tag("remove") 
                cyl(r = r - wall, h = width + 2 * wall, rounding = -5, teardrop = true,anchor = BOT);
    }