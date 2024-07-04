include <BOSL2/std.scad>
$align_msg = false;
$fn = 72;
d_body = 22;
h_body = 37;
d_cap = 24;
h_cap = 12;
wall = 2;
c_box = true;           //dimensioned for cardboard box
top = true;             //rack for top layer
plate =     c_box ? [120,130,wall] : [150,150,wall];
grid =      c_box ? [4,5] : [5,5];           
grid_sp =   c_box ? [d_cap+2,d_cap+1] : [d_cap+3,d_cap+4]; 
h_layer =   top ? h_body - 3 : h_body - 10;
leg = [d_body * 0.7, d_body * 0.7, h_layer];


rack();

module rack() {    
    diff() {
        cuboid(plate, rounding = d_cap/2, edges = "Z", anchor = BOT){
            tag("remove") position(BOT) 
                grid_copies(spacing = grid_sp, n=grid) down(0.1) #cylinder(d=d_body, h=wall+1);
            yflip_copy() { xflip_copy() align(TOP,LEFT+BACK) down(0.01) leg(); } 
        }
    }
}

module leg() {
    tag_scope("leg") {
        
        diff() {
           color("blue") cuboid(leg, rounding = d_cap/2, edges = BACK+LEFT, anchor = BOT+BACK+LEFT) {
                move([wall,-wall, -0.5]) tag("remove")
                    cuboid(leg, rounding = d_cap/3, teardrop = true, edges = [BACK+LEFT, TOP+BACK, TOP+LEFT]);
                        move([2 * wall,-2 * wall,0.1]) tag("remove")
                            cuboid(leg, rounding = d_cap/2, edges = BACK+LEFT);
            }
        }
    }
}

