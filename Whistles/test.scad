include<BOSL2/std.scad>
$fn = 32;
diff() {
    cuboid([10,30,5]){
        //align([BACK,FWD], inside = true, shiftout=-5) cyl(h = 5.01, d = 4);
        align(TOP, BACK, inset=5, inside = true, shiftout=.005) cyl(h = 5.01, d = 4);

    }
}
