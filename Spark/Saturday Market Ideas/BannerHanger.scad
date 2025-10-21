include<BOSL2/std.scad>
include<BOSL2/screws.scad>



part = "bolt";   //[bolt,ring]

d_rod = 1.25 * INCH;  // Rod Diameter
wall = 3;
body = [25,62,10];
ring = [21,undef,d_rod + 2 * wall];
round = 2;


$fn = 72;

if (part == "ring"){
    diff(){
        cuboid([ring.x,ring.z,ring.z *.75],  rounding = round, except = TOP, anchor = BOT+BACK){
            position(FWD)down(7) screw_hole(str("M8,",d_rod + 2 * wall), oversize = .25, anchor = TOP, thread = true, bevel = true, orient = FWD);
            position(TOP) xcyl(h = ring.x, d = ring.z, rounding = round)
            tag("remove") xcyl(h = ring.x, d = d_rod, rounding = -wall/2);
        }
    }
}


if (part == "bolt") {
    spec = screw_info("M8,18", head="socket", drive = "hex");
    newspec = struct_set(spec,["head_size",25,"head_height", 8, "drive_size", 9.5]);
    echo(spec);
    echo("---");
    echo(newspec);
    
    screw(newspec);
}
