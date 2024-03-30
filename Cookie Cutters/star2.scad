include <BOSL2/std.scad>

$fn = 36;
od = 40;
width = 1;
height = 15;
base = 3;

star1 = [star(n = 5, od = od, id = od/2, align_tip = BACK)];

star2 = offset(star1,1);
star3 = offset(star1,1.5);
star4 = offset(star1,3);

region = [star2,star4]; 
path1 = [up(0), up(base)];
sweep(region, path1);

region2 = [star2, star3];
path2 = [up(0), up(height)];
sweep(region2, path2);

region3 = [offset(star1, 0.75)];
sweep(region3, path1);
color("blue") cyl(d = 10, h = 15, anchor = BOT);
