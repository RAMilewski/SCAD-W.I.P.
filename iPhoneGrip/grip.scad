include<BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/screws.scad>
$fn = 64;
$align_msg = false;

slot = [25, 13, 79];
d_grip = 42;
shoe = [d_grip, slot.y + 8, 85];
remote = [34,50.5,12];
corner = 5;
window = [19,5,67.5];



//right_half(s=200) 
grip();

module grip() {
    diff() {
        cuboid(shoe, rounding = corner, except = [BACK, BACK+RIGHT], teardrop = true, anchor = BOT){
            //back window
            tag("remove") position(FWD+LEFT) 
                cuboid(window, rounding = corner, except = LEFT, edges = "Y", anchor = FWD+LEFT);
            //iphone slot
            tag("remove") align(LEFT, inside = true) fwd(1) cuboid(slot, rounding = 5, except = LEFT);
            //shutter release slot
            tag("remove") attach(TOP,LEFT) back(slot.y-2) down(21) xrot(-15)
                rounded_prism(glued_circles(d = remote.x, spread = 20, tangent = 0), 
                height = remote.z, joint_top=6, joint_bot=6, k = 0.6); 
            //round grip
            position(BACK+RIGHT) back_half(s = 100) 
                cyl(h = shoe.z, d = d_grip, rounding = corner, teardrop = true, anchor = RIGHT)
                attach(BOT,TOP,inside=true) screw_hole("1/4-20,1", thread=true, bevel1="reverse");

        }
    }
}
