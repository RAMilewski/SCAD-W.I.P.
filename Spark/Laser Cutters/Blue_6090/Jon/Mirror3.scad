include<BOSL2/std.scad>

shell = [46,46,15];
disc = [8.5,undef,8.1];
plate = [41,41,shell.z];
stamp = [40,40,1];
aperture = 16.7;
$fn = 72;

//back_half() 
stamp();


module m3() { import("Mirror3Target.stl"); }

module holder() {
    diff() {
        cuboid(shell, rounding = 3, except = BOT, anchor = BOT) {
            tag("remove") position(BOT){
                up(disc.z+1) cuboid(plate, anchor = BOT);
                cyl(h = disc.z+1.01, r = disc.x, rounding2 = -2, anchor = BOT);
            }
        }
    }
    //color("dodgerblue") up(disc.z+1.5) xrot(180) m3();
}

module stamp() {
    cuboid(stamp, rounding = 3, edges = "Z", anchor = BOT)
        position(TOP){
            xcopies(n=3, spacing = 11) cuboid([1,stamp.y,1], anchor = BOT);
            ycopies(n=3, spacing = 11) cuboid([stamp.x,1,1], anchor = BOT);
            tube(id = aperture, wall = 1, h = 1, anchor = BOT);
        }
}

module handle() {
    cuboid([stamp.x, stamp.y, 3], rounding = 3, edges = ["Z",TOP], anchor = BOT)
        position(TOP) cyl(h = 25, d = 15, rounding1 = -5, rounding2 = 7.5, anchor = BOT);
}