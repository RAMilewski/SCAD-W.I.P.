include <BOSL2/std.scad>
include <ToolRack.scad>

width = 40;
depth = 25;

difference() {
    blank(width,depth);
    right((depth - triangle)/2 + triangle){
        up(width * .8) tag("remove") cuboid([16.5,z_blank * 1.1,8], anchor = FWD);
        up(width * .45) tag("remove") cuboid([12,z_blank * 1.1,7.5], anchor = FWD);
        up(width * .2) tag("remove") cuboid([15.9,z_blank * 1.1,5], anchor = FWD);
        up(width * .2 - 1) tag("remove")#cuboid([9,z_blank * 1.1,10], anchor = FWD);
        
    }
}