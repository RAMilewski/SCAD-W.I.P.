include <BOSL2/std.scad>
include <BOSL2/screws.scad>


spec = screw_info("9/16,3/4",head="socket", drive = "hex");
newspec = struct_set(spec,["head_size",32,"head_height", 8, "drive_size", 9.5]);
echo(newspec);
screw(newspec);
/*
 nut("9/16", $slop = 0.2);
/* */

