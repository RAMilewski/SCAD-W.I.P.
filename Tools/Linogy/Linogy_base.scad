include<BOSL2/std.scad>

box = [212,92];
base = [180,108,6];
width = 8;
corner = 1;
$fn = 64;

rotlist = [-90,180,0,90];

//arm();


cuboid([base.x,width,base.z]){
    align([LEFT,RIGHT]) arm();
    grid_copies(n = 2, spacing = [base.x,width]) fillet(r = 30, h = base.z, spin = rotlist[$idx]);
}


module arm() {
    cuboid([width,box.y+4,base.z], rounding = corner, edges = "Z")
       align(TOP,[FWD,BACK]) cuboid([width,2,2], rounding = corner, edges = "Z");
}