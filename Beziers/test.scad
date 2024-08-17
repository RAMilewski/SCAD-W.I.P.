include<BOSL2/std.scad>

$fn=32;
diff()
  conv_hull("remove")
    cuboid(10)
      #position(RIGHT+BACK)cyl(r=4,h=10)
        tag("remove")cyl(r=2,h=12);
