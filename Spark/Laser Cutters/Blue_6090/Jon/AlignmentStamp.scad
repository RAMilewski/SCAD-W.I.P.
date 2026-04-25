include<BOSL2/std.scad>

shell = [46,46,16];
disc = [10,undef,8];
plate = [37,37,shell.z];
stamp = [36,36,1];
aperture = 14;
$fn = 72;

//back_half() 
//holder(); right(shell.x) handle();  
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
            xcopies(n=3, spacing = 11) cuboid([0.75,stamp.y,1.5], anchor = BOT);
            ycopies(n=3, spacing = 11) cuboid([stamp.x,0.75,1.5], anchor = BOT);
            tube(id = aperture, wall = 0.75, h = 1.5, anchor = BOT);
        }
}

module handle() {
    cuboid([stamp.x, stamp.y, 3], rounding = 3, edges = ["Z",TOP], anchor = BOT)
        position(TOP) cyl(h = 25, d = 15, rounding1 = -5, rounding2 = 7.5, anchor = BOT);
}