include <BOSL2/std.scad>

$fn = 12;

h = 1;
d1 = 1;
d2 = 1.5;
backing = 0.5;
//d2 multiplier
spacing = 0.9;
field = [25,25];
count = [floor(field.x/(spacing*d2)), floor(field.y/(spacing*d2))];
echo(count);
border = 5;






/*
cuboid([field.x + border, field.y + border, backing]) {
    position(RIGHT) cyl(h = backing, d = field.y + border, $fn = 72);
    
    position(TOP) grid_copies(size = field, n = count, stagger = true) 
        cyl(h = h, d = d1, anchor = BOT)
            attach(TOP,CTR) spheroid(d = d2);
}
*/