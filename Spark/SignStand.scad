/*#################################################################################*\
   SignStand.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            Stand for Laminated Sign
   	

	Version:                1.0
	Creation Date:          4 Nov 2022
	Modification Date:      
	Email:                  richard+scad@milewski.org
	Copyright 				©2022 by Richard A. Milewski
    License - CC-BY-NC      https://creativecommons.org/licenses/by-nc/3.0/ 

\*#################################################################################*/


/*#################################################################################*\
    
    Notes

\*#################################################################################*/


/*#################################################################################*\
    
    CONFIGURATION

\*#################################################################################*/
include <BOSL2/std.scad>

$fn = 72;

base = ([50, 5, 15]);
mast = ([5, 170, 15]);
slot = ([1, 120, 10]);
hole_dia = 2.4;


module hide_variables () {}  // variables below hidden from Customizer

/*#################################################################################*\
    
    Main

\*#################################################################################*/
union() {
	fwd((mast.y+base.y-mast.x)/2)  cuboid(base, rounding = mast.x/2, edges = "Z", anchor = BOT);
	difference() {
			cuboid(mast, rounding = mast.x/2, edges = "Z", anchor = BOT);
			union() {
				up((mast.z-slot.z)) back((mast.y-slot.y)/2) color("red") cuboid(slot, anchor = BOT);
				up(mast.z/2) color("blue") xcyl(d = hole_dia, h = mast.x);
			}
	}	
    color("green")
    fwd((mast.y-mast.x)/2) {
		right(mast.x/2)
		interior_fillet(l=mast.z, r=(base.x/2-mast.x), orient=UP, anchor = BOT);
		left(mast.x/2)
		interior_fillet(l=mast.z, r=(base.x/2-mast.x), orient=DOWN, anchor = TOP);
	}
}

/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module echo2(arg) {
	echo(str("\n\n", arg, "\n\n" ));
}