include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
diff("remove")
  cuboid([50,30,10]){
    attach(BACK) dovetail("male", taper = 5, slide=10, width=15, height=8, chamfer=1);
    tag("remove")attach(FRONT) dovetail("female", taper = 5, slide=10, width=15, height=8,chamfer=1);
  }