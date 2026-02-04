/*#################################################################################*\
   FanShroud.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            Dryer Vent Tubing Adapter for Exaust Fan
   	

	Version:                1.1
	Creation Date:          25 Jan 2023
	Modification Date:      29 Jan 2023
	Email:                  richard+scad@milewski.org
	Copyright: 				©2023 by Richard A. Milewski
    License:                MIT License     

\*#################################################################################*/


/*#################################################################################*\
    
    Notes

\*#################################################################################*/


/*#################################################################################*\
    
    CONFIGURATION

\*#################################################################################*/
include <BOSL2/std.scad>

part = "wall";              //[room, wall, plate]

module hide_variables () {} // variables below hidden from Customizer

$fn = 72;
epsilon = 0.1;              // fix for preview rendering issue

vent_dia = 4 * INCH;
vent_fudge = 4;
wall = 2;

fan_face = ([119,119,wall]);
fan_Z = 39;
fan_port = (114);
mount_hole = 4.5;
mount_centers = [104,104];

/*#################################################################################*\
    
    Main

\*#################################################################################*/
	if (part == "room") room_part();

    if (part == "wall") wall_part();

    if (part == "plate") mount_plate();


/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module mount_plate() {
    difference() {
        cuboid(fan_face, rounding = 4, edges = "Z", anchor = BOT);
        union() {
            down(epsilon/2) cyl(d = fan_port, h = fan_face.z + epsilon, anchor = BOT);
            grid_copies(spacing = mount_centers)
                down(epsilon/2) cyl(h = fan_face.z + epsilon, d = mount_hole, anchor = BOT);
        }
    }
}

module room_part() {
    mount_plate();
    tube(id1 = fan_port, id2 = vent_dia, wall = wall, h = 10, anchor = BOT);
    up(10) tube(id1 = vent_dia, id2 = vent_dia - 3, h = 25, wall = wall, anchor = BOT);

}

module wall_part() {
    mount_plate();
    tube(id1 = fan_port, id2 = vent_dia + vent_fudge, wall = wall, h = 10, anchor = BOT);
    difference() {
        up(10) tube(id= vent_dia + vent_fudge, h = 10, wall = wall, anchor = BOT);
        up(15) xcyl(h = fan_face.x, d = mount_hole);
    }
}

module echo2(arg) {
	echo(str("\n\n", arg, "\n\n" ));
}