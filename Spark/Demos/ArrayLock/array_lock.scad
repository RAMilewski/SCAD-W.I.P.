include <BOSL2/std.scad>

/* [Overall Size] */
field = [25,25];
backing = 0.4;
tab = true;
/* [Post Paramaters] */
h = 0.6;
d1 = 1;
d2 = 1.5;
ang = 20;
cap = 1; 
/* [Post Spacing] */
//spacing is a multiple of d2
spacing = 0.9;
border = 3;
count = [floor(field.x/(spacing*d2)), floor(field.y/(spacing*d2))];
echo(count);
/* [Smoothness] */
$fn = 24;


    cuboid([field.x + border, field.y + border, backing]) {
        if (tab) position(RIGHT) cyl(h = backing, d = field.y + border, $fn = 72);
        position(TOP) grid_copies(size = field, n = count, stagger = true) 
            cyl(h = h, d = d1, rounding1 = -.3, anchor = BOT)
                attach(TOP,TOP) onion(d = d2, ang = ang, cap_h = cap, realign = true);
    }