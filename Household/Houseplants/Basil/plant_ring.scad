include<BOSL2/std.scad>

$fn = 72;

r = 30;
size = [5,2];

path = arc(r=r, start=-90, angle=180, wedge=false);

diff() {
    path_sweep(rect(size), path){
        position(TOP+BACK) fwd(size.x/2) cyl(h = 2, d1 = size.x-1, d2 = size.x/2, anchor = BOT);
        ycopies (n = 2, spacing = r*2) cyl(h = size.y, d = size.x);
        position(FWD) back(size.x/2) tag("remove") cyl(h = size.y + EPSILON, d1 = size.x - 0.75, d2 = size.x / 2);
        position(TOP+RIGHT) left(size.x/2) xscale(0.5) cyl(h = 90, d1 = size.x * 2, d2 = size.x/4, anchor = BOT);
    }
}