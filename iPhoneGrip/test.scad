include<BOSL2/std.scad>


$fn = 72;

//back_half(s = 200)
diff()
    cuboid([75,20,20], rounding = 3) xcopies(n=5, l = 50) {
        tag("remove") attach(TOP,TOP, inside = true) cyl(h = 20, d = 7.15, chamfer1 = -1, rounding2 = -1);
        //tag("remove") attach(TOP,TOP, inside = true) cyl(h = 1, d1 = 7.15, d2 = 7.5);
    }