include<BOSL2/std.scad>
include<BOSL2/screws.scad>



part = "ring";   //[bolt,ring]

d_rod = 1.25 * INCH;  // Rod Diameter
wall = 3;
body = [25,62,10];
ring = [21,undef,d_rod + 2 * wall];
round = 2;


$fn = 72;

if (part == "ring"){
    diff(){
        cuboid([ring.x,ring.z,ring.z *.75],  rounding = round, except = TOP, anchor = BOT+BACK){
            tag("remove") position(FWD) down(7) #ycyl(l = ring.z - 5, d = 7.5, anchor = FWD); //for heat insert
            position(TOP) xcyl(h = ring.x, d = ring.z, rounding = round)
            tag("remove") xcyl(h = ring.x, d = d_rod, rounding = -wall/2);
        }
    }
}


if (part == "bolt") {
    spec = screw_info("1/4-20,3/4", head="socket", drive = "hex");
    newspec = struct_set(spec,["head_size",18,"head_height", 8, "drive_size", 5]);
    echo(spec);
    echo("---");
    echo(newspec);
    
    screw(newspec);
}
