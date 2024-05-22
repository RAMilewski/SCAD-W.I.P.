include<BOSL2/std.scad>

$fn = 72;

dia = 35;                   // beeswax disk diameter
base = [dia+5,dia+5,13];    // base size
corner = 3;                 // corner radius

base();


module cup() {
    difference() {
        cyl(d = dia, h = base.z + 10, anchor = BOT);
        up(base.z) torus(r_maj = dia/2 + 0.6, r_min = 1);
    }
}

module base() {
    diff(){
        cuboid(base, rounding = corner, edges = "Z", anchor = BOT);
        tag("remove")  cyl(d = dia+1, circum = true, h = base.z+1, anchor = BOT);
        
    }
}

