include <BOSL2/std.scad>
include <BOSL2/hinges.scad>
$fn=32;
thickness=2;
clearance=0.2;
zrot_copies([0,180])
  color(["green","gold"][$idx])
  diff()
    xrot(180*$idx, cp=[0, 0, 7/2+thickness*2/3 + clearance])
    fwd(clearance/2)
      cuboid([20,thickness+1,7],anchor=BACK) {
        down(thickness/3)
        position(TOP+BACK)
          knuckle_hinge(20, segs=5, offset=thickness+clearance,
                        inner=$idx==0,
                        knuckle_clearance=clearance,  // comment out this line to see the in_place pins
                        clearance=clearance/2, arm_angle=90,
                        knuckle_diam=2*thickness+clearance,
                        clear_top=true, in_place=true);
        attach(TOP, BOTTOM, align=FRONT)
            cuboid([20, thickness, thickness-2.5*clearance]);
      }