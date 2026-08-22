
include <BOSL2/std.scad>	// https://github.com/revarbat/BOSL2/wiki
include <BOSL2/screws.scad>
include <BOSL2/rounding.scad>

tilt = 75;               //angle of controller


module hide_variables () {}  // variables below hidden from Customizer

$fn = 72;                //openSCAD roundness variable
eps = 0.01;              //fudge factor to display holes properly in preview mode
$slop = 0.025;			 //printer dependent fudge factor for nested parts


wall_plate = [120,119,4];    //wall plate dimensions
standoff = [19,19,90];       //standoff dimensions
d_elbow = 19;                //diameter of 90˚ elbow
h_elbow = 25 - wall_plate.z; //distance from wall plate to elbow

hole_spacing = (wall_plate.x - standoff.x) / 2 + standoff.x; 

shape = rect(20, rounding = 4);
   
   diff() {
        fwd(30) cuboid (wall_plate, rounding = 4, edges = ["Z",TOP], anchor = TOP){
            tag_scope(){
                diff(){
                    align(TOP,BACK) fwd(4) cuboid([d_elbow + 15, 20, h_elbow + d_elbow/2], rounding = 3, edges = ["Z",TOP], anchor = BOT){
                        tag("remove") position(TOP) ycyl(h = 20, d = d_elbow);
                        tag("remove") position(TOP) yscale(3) xrot(90) #torus(d_maj = d_elbow + 5, d_min = 2);
                    }
                }
            }
            
            align(TOP,FWD) back(4) cuboid([27,27,14.25], rounding = 4, edges = ["Z",TOP], anchor = BOT) {
                tag("remove") align(BACK, inside = true) cuboid([13,17,14.5])
                    tag("remove") back(2) #xcyl(d = 5.75, h = 30);   
                    if ($preview) back(7) right(20) rot([90,0,90]) ruler(); 
            }         
        }
        tag("remove") fwd(30) grid_copies( spacing = [100,80])
            screw_hole("#6",l = wall_plate.z + 0.1, head="flat sharp",
                counterbore=0,anchor=TOP);
    }



   