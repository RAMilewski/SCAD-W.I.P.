include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 144;

part = "Bolt";  //[Nut,Bolt,Tool]

newpitch = 2.2;


right(40) screw("9/16,1/2", head = "socket" );

if (part == "Bolt") {
    spec = screw_info("9/16,3/4", head="socket", drive = "hex");
    newspec = struct_set(spec,["head_size",32,"head_height", 8, "drive_size", 9.5,"pitch",newpitch]);
    echo(spec);
    echo("---");
    echo(newspec);
    
    screw(newspec);
}


if (part == "Nut") {
    //nut("9/16", $slop = 0.2);

    spec = nut_info("9/16");
    newspec = struct_set(spec, ["pitch",newpitch]);
    echo(spec);
    echo("---");
    echo(newspec);
    
    nut(newspec, $slop = 0.2);
}

if (part == "Tool") {
    xrot(360/16) xcyl(d1 = 9.1, d2= 9.25, l = 50, $fn = 6, rounding = 1.5, circum = true);

}

/* */

