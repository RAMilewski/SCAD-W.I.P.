/*#################################################################################*\
    Snowflake_Stencil.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            
   	

	Version:                1.0
	Creation Date:          
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
module hide_variables () {}  // variables below hidden from Customizer

/*#################################################################################*\
    
    Main

\*#################################################################################*/
difference(){
    color("blue") 
    cuboid([100,100,1], rounding = 5, edges = "Z", anchor = BOT);
        difference() {
            down(0.5) scale([0.4,0.41,0.1]) surface("Snowflake_100.png", center = true);	
            down(1) cuboid([100,100,1], anchor = TOP);  
        }
} 

fwd(0.5){
    xcopies(spacing = 7, n = 3) cyl(h=5, d=2, anchor = BOT);
    up(5) cuboid([16, 2, 1], rounding = 1, edges = "Z", anchor = BOT);
}
/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module echo2(arg) {
	echo(str("\n\n", arg, "\n\n" ));
}