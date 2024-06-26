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
plate = [150,150,wall];
grid = [5,5];

rack();

module rack() {    
    diff() {
        cuboid(plate, rounding = d_cap/2, edges = "Z", anchor = BOT){
            tag("remove") position(BOT) grid_copies(spacing = d_cap+3, n=grid) #cylinder(d=d_body, h=wall);
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

