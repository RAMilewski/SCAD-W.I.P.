// Written in OpenSCAD - Use the most recent snapshot (https://openscad.org/downloads.html#snapshots)
// Do not use the release version. (2021.01)
// OpenSCAD mailing list archive: https://lists.openscad.org/empathy/list/discuss.lists.openscad.org

include <BOSL2/std.scad>  // https://github.com/BelfrySCAD/BOSL2
// Use the wiki docs, the PDF is 2000+ pages.
// For the terminally befuddled, the BOSL2 devs hang out at: 
// https://app.gitter.im/#/room/#revarbat_BOSL2:gitter.im they're nice folks and like to help.

// You can adjust the parameters below using the OpenSCAD Customizer. $



$fn = 72;       //Trust me.
dia = 19;       //Diameter of the soldering iron handle (the cool segment).
z_dim = 30;     //Height of the clamp holding the iron. (Use M3 hardware to secure the clamp).
w_dia = 31.75;  //Diameter of the washer at the other end of the arm.
l_arm = 66;     //Distance from the center of the iron to the center of the drill press chuck.
p_bolt = 5;     //Height of the square part of the carriage bolt. From ASME B18.5, Table 2
d_bolt = 9.86;  //Diameter of the threaded shaft of the 3/8 inch carriage bolt.

iron_clamp(); arm();  // This could be done as one continuous bit of code instead of two modules, but
                        // multiply nesting tag scopes leaves you in a twisty little maze of code
                        // passages all the same.  It could be done with tag_scope(), but not by me.

module iron_clamp() {
    partition([50,50,50], spread = 5, cutsize = 50, cutpath = "flat"){
        diff() {
            cyl(h = z_dim, d = 1.5 * dia)
                align([LEFT,RIGHT], overlap = 3) ycyl(l = 8, d = 11, rounding = 2, anchor = BOT){
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
            tag("remove") back(l_arm) down(z_dim/2) cuboid([d_bolt,d_bolt,p_bolt], anchor = BOT); //bolt head hole
            tag("remove") back(l_arm) cyl(h = 1.25, d = w_dia, anchor = TOP);   //washer channel
            tag("remove") cyl(h = z_dim/2, d = 1.5 * dia, anchor = TOP); //clamp cutout

        }
    }
}