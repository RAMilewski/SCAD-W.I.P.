include<BOSL2/std.scad>

if ($preview) move([10, -21.5, -3]) import("internal.stl");

$fn = 72;

body = [11,60,6];
body_r = 2;
tone1 = 10;
tone2 = 25;
t1_hole = true;


if ($preview) { bottom_half() body(); } else { body(); }


module body() {
    diff() {
        back(10) cuboid(body, rounding = body_r, edges = "Z"){
            align(BACK, inside = true, shiftout = -2) cyl(h = body.z, d = 4, rounding = -1);  //lanyard hole
            tag("remove")  xflip_copy() left(0.75) align(FWD, inside = true, shiftout = 1) channel();
            tag("remove")  xflip_copy() left(2) align(BACK, inside = true, shiftout = -8) color("blue") cuboid([3.2,40,4], anchor = FWD)
                    position(FWD+LEFT) left(0.6) yrot(90) #wedge([4,5,3], anchor = FWD);                  
            tag("remove")  xflip_copy() left(3.5) align(BACK, inside = true, shiftout = -8) color("red") cuboid([1.7,36,4], anchor = FWD);
        
            // Tuning Hole
            tag("remove") position(TOP) left(2.5) #cyl(h = 2, d = 3, anchor = TOP);

            // Tuning Plugs
            tag("keep") left(2.5) align(BACK, inside = true, shiftout = -(8 + tone1)) cuboid([4.1,1,4], anchor = FWD);
            tag("keep") right(2.5) align(BACK, inside = true, shiftout = -(8 + tone2)) cuboid([4.1,1,4], anchor = FWD);
        
        }
    }
}

module channel() {
    path = zrot(94,catenary(13,droop = 0.7));
    color("lightgreen")#path_sweep(rect([3,4]), path, scale = [.4,1],anchor = BACK);
}

//zrot(-90) ruler();