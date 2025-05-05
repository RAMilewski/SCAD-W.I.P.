include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 144;

part = "Nut";  //[Nut,Bolt]

newpitch = 2.1;


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


/* */

