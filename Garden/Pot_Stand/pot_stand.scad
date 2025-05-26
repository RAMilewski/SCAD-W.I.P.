include<BOSL2/std.scad>
$fn = 144;

diff() {
    rounded_prism(rect([125,50]), apply(left(12.5),rect([100,50])), h = 25, 
        joint_top = 5, joint_bot = 0, joint_sides = 5, anchor = BOT)
            position([TOP]) right(30) down(5) onion(r = 15, ang = 50, anchor = BOT);
                
}


/*
//up(40) ruler();

onion(8,20,10,$fn = 72)
    position(TOP) {
        shape = right(10, mask2d_roundover(r=3, mask_angle = 70));
        #rotate_sweep(shape, 360);
    
    onion(8,20, 10, $fn = 72)
                edge_profile([TOP,BOT], excess=10, convexity=6) {
                    mask2d_roundover(r=8, inset=1, excess=1, mask_angle=$edge_angle);
                }

diff()
    onion(r = 8, ang = 20, cap_h = 10) {
        edge_profile([TOP,BOT], excess=10, convexity=6) {
            mask2d_roundover(r=8, inset=0, excess=1, mask_angle=$edge_angle);
        }
}
/* */

