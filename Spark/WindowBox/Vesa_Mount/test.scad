include<BOSL2/std.scad>
include<BOSL2/turtle3d.scad>


state1 = turtle3d(["move", 20],full_state=true);
  state2 = turtle3d(["arcright", 20],state=state1,full_state=true);
  final = turtle3d(["move", 30], state=state2);
  stroke(final);
