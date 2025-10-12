include<BOSL2/std.scad>

d = 77.5;
h = 80;
wall = 2;


rgn = right(d/2,rect([1,h]));

$fn = 32;

//back_half(s=300)
diff(){
      cyl(d = d, h = 5, anchor = BOT) {
        grid_copies(size=d, n=15, stagger=true) tag("remove") position(BOT) cylinder(d=8, h=5, $fn = 6, anchor = BOT);
        position(BOT) tag("keep") tube(od = d+1, h = 5, anchor = BOT);
        position(BOT) cyl(d = d+1, h = 1, anchor = TOP);
        position(TOP) rotate_sweep(rgn, anchor = BOT)
           up(1.2) zrot_copies(n = 32) zcopies(n = 11, spacing = 7,) tag("remove") ycyl(d = 6.5, l = d + 1, $fn = 4);
    }
}

/* */