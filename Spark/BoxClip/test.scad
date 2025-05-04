include<BOSL2/std.scad>
include<BOSL2/screws.scad>

left(15)
screw("9/16,7/8", blunt_start = false, bevel = true, head = "socket")
    echo($screw_spec);



spec = screw_info("9/16,7/8", blunt_start = false, bevel = true, head = "socket");

right (15) 
    screw(spec)
        echo($screw_spec);

        /* */ 