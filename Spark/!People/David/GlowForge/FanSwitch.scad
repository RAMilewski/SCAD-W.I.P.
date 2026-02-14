include<BOSL2/std.scad>

$fn = 72;

base = [60,65,3];
post = 5;

diff() {
    cuboid(base, rounding = 5, edges = "Z", except = BACK){
        align(TOP, BACK) xcopies(n = 2, spacing = base.x - post) 
            cuboid(post, rounding = post/2, edges = "X", except = BOT)
                tag("remove") xcyl(l = post + .1, d = 2.5);
         tag("remove") fwd(3) cyl(h = base.z + .1, d = 42, rounding2 = -base.z/2);

    }
}
//up(base.z) fwd(32.5) zrot(90) ruler();