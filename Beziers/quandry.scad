include<BOSL2/std.scad>
$fn = 32;

  cuboid([30,10,5], rounding = 5, edges = "Z", except=BACK)
      align(BACK,[LEFT,RIGHT]) cuboid([10,10,5],rounding=5,edges="Z", except=FRONT);