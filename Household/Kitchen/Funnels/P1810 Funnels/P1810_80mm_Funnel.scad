/*#################################################################################*\
   P1810_80mm_Funnel.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            
   	

	Version:                1.0
	Creation Date:          3 July 2023
	Modification Date:      
	Email:                  richard+scad@milewski.org
	Copyright 				©2023 by Richard A. Milewski
    License - CC-BY-NC      https://creativecommons.org/licenses/by-nc/3.0/ 

\*#################################################################################*/


/*#################################################################################*\
    
    Notes

	Requires the BOSL2 library for OpenSCAD  https://github.com/revarbat/BOSL2/wiki

\*#################################################################################*/


/*#################################################################################*\
    
    CONFIGURATION

\*#################################################################################*/
include <BOSL2/std.scad>	// https://github.com/revarbat/BOSL2/wiki
include <BOSL2/bottlecaps.scad>

module hide_variables () {}  // variables below hidden from Customizer

$fn = 72;               //openSCAD roundness variable
eps = 0.01;             //fudge factor to display holes properly in preview mode
$slop = 0.025;			//printer dependent fudge factor for nested parts
 
fid = 80;               //funnel top id 
hole = 28;              //cap hole id
wall = 2.3;               //funnel wall thickness
/*#################################################################################*\
    
    Main

\*#################################################################################*/

   tube(id1 = fid, id2 = hole, wall = wall, h = fid/2, anchor = BOT)
    attach(TOP) cap();
  

/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module cap () {
    difference() {
        pco1810_cap(texture="none", anchor = BOT);
        cyl(d = hole, h = 3, circum = true, anchor = BOT);
    }
}

module echo2(arg) {						// for debugging - puts space around the echo.
	echo(str("\n\n", arg, "\n\n" ));
}