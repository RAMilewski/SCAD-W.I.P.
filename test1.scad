include <BOSL2/std.scad>
diff() {
//  linear_extrude(10)
//    polygon(points=[[1, 1], [-1, 1], [-1, -1], [1, -1]]);
  path =[[1, 1], [-1, 1], [-1, -1], [1, -1]];  
  linear_sweep(path,10);
  tag("remove")
  cube(2);
}

left(5)
diff() {
  linear_extrude(10)
    square(2, center=true) show_anchors();
  tag("remove")
  cube(2);
}

left(10)
diff() {
  cube([2, 2, 10], anchor=BOTTOM);
  tag("remove")
  cube(2);
}