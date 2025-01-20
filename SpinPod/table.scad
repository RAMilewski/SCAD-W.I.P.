include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

table = [50, undef, 3]; 
mount = [60,11,35];
slot_depth = 13;
peg = [10, undef, mount.z - slot_depth];
corner = 3;

d_spinpod = 95;
mount_offset = 21 - mount.y/2;

$fn = 64;

cyl(table.z, table.x, rounding = table.z/2, teardrop = true, anchor = BOT){
    position(TOP) fwd(mount_offset) rounded_prism(square([mount.x,mount.y]), height=mount.z, joint_top=corner,
        joint_bot=-3.5 * corner, joint_sides=corner, k=0.3, splinesteps=32, anchor = BOT);
    position(TOP) back(mount_offset) 
        xcopies(l = d_spinpod * .6) cyl(h = peg.z, d = peg.x, rounding1 = -5, anchor = BOT);
}