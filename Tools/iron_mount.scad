include <BOSL2/std.scad>

$fn = 72;
dia = 19;
z_dim = 30;
w_dia = 31.75;
l_arm = 66;
p_bolt = 5;
d_bolt = 9.86;

iron_clamp(); arm();

module iron_clamp() {
    partition([50,50,50], spread = 5, cutsize = 50, cutpath = "flat"){
        diff() {
            cyl(h = z_dim, d = 1.5 * dia)
                align([LEFT,RIGHT], overlap = 3)  ycyl(l = 8, d = 11, rounding = 2){
                    tag("remove") position(BACK) yrot(30) ycyl(l = 3, d = 5.6, $fn = 6, circum = true);
                    tag("remove") ycyl(l = 10, d = 3.25);
                }
                tag("remove") cyl(h = z_dim, d = dia, rounding = -3);
        }
    }
}

module arm() {
    diff() {
        conv_hull("keep") 
            back(2.5) cyl(h = z_dim/2, d = 1.5 * dia - 1, rounding = 2, anchor = TOP){
                back(l_arm) cyl(h = z_dim/2, d = w_dia + 4, rounding = 2);
            }
        back(2.5) {
            tag("remove") back(l_arm) cyl(d = d_bolt, h = z_dim/2, anchor = TOP); //bolt hole
            tag("remove") back(l_arm) down(z_dim/2) #cuboid([d_bolt,d_bolt,p_bolt], anchor = BOT); //bolt head hole
            tag("remove") back(l_arm) cyl(h = 1.25, d = w_dia, anchor = TOP);   //washer channel
            tag("remove") cyl(h = z_dim/2, d = 1.5 * dia, anchor = TOP); //clamp cutout

        }
    }
}