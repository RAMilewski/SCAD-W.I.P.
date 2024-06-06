include<BOSL2/std.scad>
$fn = 144;
diff() {
    cuboid([175,135,2], rounding = 25, edges = "Z");
        tag("remove") xscale(165/110) cyl(d=110, h = 4);
}