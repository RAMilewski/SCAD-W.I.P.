/*#################################################################################*\
   SpiceJarFunnel.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            Funnel for filling Winco Plastic Spice Jars
   	

	Version:                1.0
	Creation Date:          Nov 7, 2022
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
$slop = -.25;		//nesting clearance

part = "lid";		//[lid,funnel]

deck = [62, undef, 2];	//[dia, undef, height]
ring = [55, 1, 12];		//[dia, wall,  height]
neck = [31, undef, 10];	//[dia, undef, height]



funnel = [85, neck.x - $slop, 30, 1.5]; //[d1, d2, height, thickness]


module hide_variables () {}  // variables below hidden from Customizer

/*#################################################################################*\
    
    Main

\*#################################################################################*/
	
   if (part == "lid") lid();
   if (part == "funnel") funnel(); 

/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module lid() {
	difference() {
		cyl(d = deck.x, h = deck.z, anchor = BOT);
		cyl(d = neck.x, h = neck.z, anchor = BOT);
	}	
	tube(od = ring.x, wall = ring.y, l = ring.z, anchor = BOT);
}

module funnel() {
	tube(od1 = funnel.x, od2 = funnel.y, l = funnel.z, wall = funnel[4], anchor = BOT);
	up(funnel.z) tube(od = funnel.y, wall = funnel[4], l = neck.z, anchor = BOT);
}

module echo2(arg) {
	echo(str("\n\n", arg, "\n\n" ));
}