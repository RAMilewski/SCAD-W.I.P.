include<BOSL2/std.scad>
$fn= 400;
diff() {
    cyl(h = 10, d = 106)
        position(TOP) tag("remove") cyl(h = 8, d1 = 100.6, d2 = 103, anchor = TOP);
}