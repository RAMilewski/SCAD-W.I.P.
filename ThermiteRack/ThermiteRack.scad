include <BOSL2/std.scad>
$align_msg = false;
$fn = 72;
d_body = 22;
h_body = 37;
d_cap = 24;
h_cap = 12;
h_layer = h_body + 5;
leg = [d_body, d_body, h_layer];
wall = 2;
c_box = true;           //dimensioned for cardboard box
plate =     c_box ? [120,150,wall] : [150,150,wall];
grid =      c_box ? [4,5] : [5,5];           
grid_sp =   c_box ? [d_cap+2,d_cap+1] : [d_cap+3,d_cap+4]; 
stagger = false;

rack();

module rack() {    
    diff() {
        cuboid(plate, rounding = d_cap/2, edges = "Z", anchor = BOT){
            tag("remove") position(BOT) 
                grid_copies(spacing = grid_sp, n=grid, stagger = stagger) down(0.1) #cylinder(d=d_body, h=wall+1);
            yflip_copy() { xflip_copy() align(TOP,LEFT+BACK) leg(); } 
        }
    }
}

module leg() {
    tag_scope("leg") {
        diff() {
            cuboid(leg, rounding = d_cap/2, edges = BACK+LEFT, anchor = BOT+BACK+LEFT) {
                move([wall,-wall, -0.5]) tag("remove")
                    cuboid(leg, rounding = d_cap/3, teardrop = true, edges = [BACK+LEFT, TOP+BACK, TOP+LEFT]);
                        move([3* wall,-3 * wall,0.1]) tag("remove")
                            cuboid(leg, rounding = d_cap/2, edges = BACK+LEFT);
            }
        }
    }
}

