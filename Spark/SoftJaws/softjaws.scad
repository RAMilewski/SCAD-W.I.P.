/*#################################################################################*\
   softjaws.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            Soft Jaws for Spark Studio Vise
   	

	Version:                1.0
	Creation Date:          28 April 2023
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

eps = .1;
fudge = 1;
jaw_size = [140 + fudge, 12, 20];
wall = 2;

module hide_variables () {}  // variables below hidden from Customizer

jaw_space = jaw_size + [0, wall, wall];
frame = add_scalar(jaw_size, wall * 2);
face = [frame.x, 5, frame.z];

/*#################################################################################*\
    
    Main

\*#################################################################################*/
	
   frame();
    fwd(frame.y/2) face_A();
   
/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module frame ()
	difference() {
		cuboid(frame, rounding = 1, except = FWD, anchor = BOT);
		back(wall/2+eps) down(eps) cuboid(jaw_space, anchor = BOT);
	}

module face_A () // For clamping round things
		diff() {
			cuboid(face, rounding = 1, edges = "Y", anchor = BACK + BOT)
			attach(FWD) {
			
				xrot(180) {
					tag("remove") prismoid(h = face.y, size1 = [frame.x, 2* face.y], size2 = [frame.x, 0], anchor = BOT);
					zrot(90) tag("remove") prismoid(h = face.y, size1 = [frame.z, 2* face.y], size2 = [frame.z, 0], anchor = BOT);
				}
			
			}
		}


module echo2(arg) {
	echo(str("\n\n", arg, "\n\n" ));
}