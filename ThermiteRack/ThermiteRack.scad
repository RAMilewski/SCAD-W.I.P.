include <BOSL2/std.scad>
$align_msg = false;
$fn = 72;
d_body = 22;
h_body = 37;
d_cap = 24;
h_cap = 12;
h_layer = h_body + 5;
wall = 3;
plate = [150,150,wall];
grid = [5,5];

plate();

module plate() {    
    diff() {
        cuboid(plate, rounding = d_cap/2, edges = "Z", anchor = BOT){
            tag("remove")  grid_copies(spacing = d_cap+3, n=grid, stagger=false) cylinder(d=d_body, h=wall+.1);
            yflip_copy() {xflip_copy() align(TOP,LEFT+BACK) leg();  } 
        }
    }
}

module leg() {
    tag_scope("leg") {
        diff() {
            cuboid([h_body, h_body, h_layer], rounding = d_cap/2, edges = BACK+LEFT, anchor = BOT+BACK+LEFT) {
                move([wall,-wall,-wall]) tag("remove")
                    cuboid([h_body, h_body, h_layer], rounding = d_cap/2, edges = BACK+LEFT);
                        move([3* wall,-3 * wall,0.1]) tag("remove")
                            cuboid([h_body, h_body, h_layer], rounding = d_cap/2, edges = BACK+LEFT);
            }
        }
    }
}

