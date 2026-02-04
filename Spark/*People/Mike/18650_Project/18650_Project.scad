/* ***************************************************************************** *\
   18650_Project.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            
   	

	Version:                1.0
	Creation Date:          10 Nov 2022
	Modification Date:      
	Email:                  richard+spark@milewski.org
	Copyright 				©2022 by Richard A. Milewski
    License                 Mozilla Public License v2.0

\* ***************************************************************************** */


/* ***************************************************************************** *\
    
    NOTES

    The variable iwall_fudge may need to be adjusted to account for printer
    over or under extrusion. It should be set to provide a snug fit for the pcb.
    Decrease it for a tighter fit, increase it to loosen the fit.

\* ***************************************************************************** */

/* ***************************************************************************** *\
    
    CONFIGURATION

\* ***************************************************************************** */
include <BOSL2/std.scad>

part = "box";           // [box, lid, button, window, test]
make_window = false;    // [true, false]

battery_count = 4;
battery_spacing = 0.4;
buffer = 5;
wall = 2;
corner = 8;
iwall_fudge = 1.25;

module hide_variables () {}  // variables below hidden from Customizer

$fn = 72;

2buffer = buffer*2;
battery = [18, 65, 18];
pcb = [30, 53.5, 1.3];
pcb_box = [30, 54, 11.4];


floor = wall;

icorner = corner - wall;
icorner2 = 1.5 * corner;      //Non std value to make fillet for screw post

battery_space = [(battery_count * (battery.x + battery_spacing)) + buffer * 2, battery.y + 2 * buffer, battery.z + buffer];

ibox = [pcb.x + wall + battery_space.x, battery_space.y, battery_space.z];
box = [ibox.x + wall * 2, ibox.y + wall * 2, ibox.z];
stacker = [box.x, box.y, buffer];

screw_post = [6, undef, stacker.z]; // post_dia, undef, post.z
screw_spacing = [ibox.x - wall - 5, ibox.y - wall - 5];
screw_hole = 2.5; //dia

// Key Locations
pcb_lift = floor + 3; 
internal_wall_loc = [-ibox.x/2 + pcb.x + wall/2 + iwall_fudge, 0, floor]; 
pcb_center = [-ibox.x/2 + pcb.x/2, 0, floor + pcb_lift + pcb.z/2];
pcb_ctr_left = pcb_center + [-pcb.x/2 , 0, 0];
pcb_back_left = pcb_ctr_left + [0, pcb.y/2, 0];
pcb_back_left_floor = pcb_back_left + [0, 0, -(pcb_lift + pcb.z/2)];
pcb_front_left = pcb_ctr_left + [0, -pcb.y/2, 0];
pcb_front_left_floor = pcb_front_left + [0, 0, -(pcb_lift + pcb.z/2)];
pcb_top = pcb_center + [0, 0, pcb.z/2];
pcb_bot = pcb_center + [0, 0, -pcb.z/2];

pcb_hole = 1.7;
pcb_post = [5, undef, pcb_lift]; // d, undef, l
pcb_post_rounding = [-3, 1.5];     // rounding1, rounding2
pcb_front_post_loc = pcb_front_left_floor + [11 + pcb_hole/2, 3.5 + pcb_hole/2, 0];
pcb_back_post_loc = pcb_back_left_floor + [13 + pcb_hole/2, -(10.25 + pcb_hole/2), 0];

pcb_support = [4, 4.5, pcb_lift];
pcb_front_support_loc = pcb_front_left_floor + [2,  1.5, 0];
pcb_back_support_loc  = pcb_back_left_floor  + [2, -1.5, 0];
pcb_right_support = [ 5, 5, pcb_lift]; 
pcb_right_support_loc = pcb_back_left_floor  + [pcb.x - 5, -10, 0]; 

pcb_stop = [8, 2, pcb_lift + 4];
pcb_front_stop_loc = pcb_front_left_floor + [2, -1.25, 0];
pcb_back_stop_loc  = pcb_back_left_floor  + [2,  1.25, 0];

battery_center = [ibox.x/2 - battery_space.x/2, 0, buffer + battery.z/2];


// Hole sizes and positions  
// usbC and lightning connectors centered under usbA connectors
led = [11, 5, 5];
led_loc = pcb_back_left + [0, -6.85, led.z/2 - 1];
led2 = [4, 17, floor + 0.1];
led2_loc = pcb_back_post_loc + [0, -(led2.y/2 + 7.5), -(floor + 0.1)]; 

usbA = [10.2, 13.5, 6];
usbAlift = 3; //connector height above pcb
usbA_loc1 =  pcb_back_left + [0, -13.25 - usbA.y/2, usbA.z/2 + usbAlift];
usbA_loc2 =  pcb_front_left + [0, 9 + usbA.y/2, usbA.z/2 + usbAlift];

usbC = [7.5, 9.2, 3.3];
usbC_loc =  [usbA_loc1.x, usbA_loc1.y , pcb_bot.z - usbC.z/2]; 

lightning = [8.73, 10, 3.5];
lightning_loc = [usbA_loc2.x, usbA_loc2.y, pcb_bot.z - lightning.z/2]; 

buttonhole = [4, 6, 4];
buttonhole_loc = [-ibox.x/2 + 19.5, ibox.y/2, pcb_center.z];
button = [3.5, 3.5, 6.5];  // button.z is doubled in the button() module. 
button_support = [8, 8, pcb_lift + 5];
button_support_loc = [-ibox.x/2 + 19.5, pcb_back_left.y + 7, floor];
button_channel = [4.1, 12, 4.1];
button_channel_loc = button_support_loc + [0, 0, pcb_lift - pcb.z] ;



/* ***************************************************************************** *\
    
    Main

\* ***************************************************************************** */
if (part == "box") {
    box();
}

if (part == "button") {
    button();
}

if (part == "lid") {
   lid();
}

if (part == "window") {
   window();
}

if (part == "test") {
    left_half(s = 200, x = internal_wall_loc.x + 2)
    bottom_half(s = 200, z = box.z * .75)
    box();
}


/* ***************************************************************************** *\
    
    Modules

\* ***************************************************************************** */


module box() {
    shell();
    internal_wall();
    if (part != "test") battery_bay();
    color_this("dodgerblue") stacker_with_posts(true);
    if ($preview && part != "test") pcb(false);
    //pcb(false);
    
}

module button() {
    cuboid([button.x * 2, button.x * 2, 1], rounding = 2, edges = "Z", anchor = BOT);
    up(1) cuboid(button, rounding = -0.5, edges = BOT, anchor = BOT);
     up(1 + button.z) cuboid(button, rounding = 1.5, edges = TOP, anchor = BOT);

}

module floor() {
    cuboid([box.x, box.y, floor], rounding = corner, edges = "Z", anchor = BOT);
}

module shell() {
    difference() {
        union() {
            floor();
            up(floor) rect_tube(h = box.z, size = [box.x, box.y], 
                wall = wall, rounding = corner, irounding = icorner2, anchor = BOT);
        }
        //shell holes
        union() {
            color("red") {
                move(led_loc) xcyl(d = led.z, l = led.x);
                if (make_window == true) {
                    move(led2_loc)  cuboid(led2, rounding = 1,   edges = "Z", anchor = BOT);
                }
                move(usbA_loc1) cuboid(usbA, rounding = 1,   edges = "X");
                move(usbA_loc2) cuboid(usbA, rounding = 1,   edges = "X");
                move(usbC_loc)  cuboid(usbC, rounding = 0.5, edges = "X");
                move(lightning_loc) cuboid(lightning, rounding = 0.5, edges = "X");
                move(buttonhole_loc) cuboid(buttonhole, rounding = 1, edges = "Y");           
            }
        }
    }
    color("dodgerblue") {
        difference() {
            union () {
                move (pcb_front_post_loc) 
                    cyl(h = pcb_post.z, d = pcb_post.x, rounding1 = pcb_post_rounding.x,
                        rounding2 = pcb_post_rounding.y, anchor = BOT);
                move (pcb_back_post_loc)  
                    cyl(h = pcb_post.z, d = pcb_post.x, rounding1 = pcb_post_rounding.x,
                        rounding2 = pcb_post_rounding.y, anchor = BOT);
                }
            union() {
                move(pcb_back_post_loc) cyl(h=pcb_post.z, d = pcb_hole, anchor = BOT);
                move(pcb_front_post_loc) cyl(h=pcb_post.z, d = pcb_hole, anchor = BOT);
            }
        }
        move (pcb_front_support_loc) cuboid(pcb_support, anchor = BOT);
        move (pcb_back_support_loc)  cuboid(pcb_support, anchor = BOT);
        move (pcb_right_support_loc) cuboid(pcb_right_support, rounding = 2, edges = "Z", anchor = BOT);
        
        move (pcb_front_stop_loc) cuboid(pcb_stop, anchor = BOT);
        move (pcb_back_stop_loc)  cuboid(pcb_stop, anchor = BOT);

        difference() {
            move (button_support_loc) cuboid(button_support, anchor = BOT);
            move (button_channel_loc) color("red") cuboid(button_channel, anchor = BOT);
        }
    }
}

module lid() {
    difference () {
        floor();
        grid_copies(n = 2, spacing = screw_spacing)
            cyl(h = screw_post.z, d = screw_hole + 1, anchor = BOT);
    } 
    up(floor) stacker(false);
      
       
           
        

}

module battery() {
    ycyl(d = battery.x,  l = battery.y);
}

module battery_bay() {
    up(floor){
        difference() {
            union() {
                move([battery_center.x, battery_center.y, floor*2]) 
                    ycopies(box.y/2) cuboid([battery_space.x, wall, battery_space.z/2]);
            }
            union() {
                move (battery_center) 
                xcopies(battery_spacing + battery.x, n = battery_count) # battery();  
            }
        }
    }
}

module internal_wall () {
     difference() {
        move(internal_wall_loc) cuboid([wall, ibox.y, ibox.z + stacker.z], anchor = BOT);
        union() {
            move(pcb_center) {   // Wire pass-through holes
                move([pcb.x/2 + wall,   pcb.y/2, 6]) xcyl(d = 3, h = 5);
                move([pcb.x/2 + wall,  -pcb.y/2, 6]) xcyl(d = 3, h = 5);
            }
        }
    }
}

module stacker_with_posts(is_male) { //stacker with screw posts
    up(box.z + floor){
        difference () {
            union() {
                stacker(is_male);
                grid_copies(n = 2, spacing = screw_spacing)
                color("white") cyl(h = screw_post.z, d = screw_post.x, rounding1 = screw_post.x/2, anchor = BOT);
            }
            grid_copies(n = 2, spacing = screw_spacing)
            cyl(h = screw_post.z, d = screw_hole, anchor = BOT);

        }
    }
}


module stacker(is_male) {	// Interface ring to stack box
     //note non-standard irounding (icorner2) in male stacker to provide screw post fillet.

	A = [box.x - 2 * wall/4, box.y - 2 * wall/4];
	B = [box.x - 4 * wall/4, box.y - 4 * wall/4];
	C = [box.x - 2 * wall,   box.y - 2 * wall];
	
	if (is_male) {
		rect_tube ( size1 = A, size2 = B, isize = C,
			h=stacker.z, rounding = corner, irounding = icorner2); //non-standard irounding
	} else {
        difference() {
            rect_tube(h = stacker.z, size = [stacker.x, stacker.y], wall = wall, 
                rounding = corner, irounding = icorner, anchor = BOT);				
            rect_tube(size1 = B, size2 = A, isize = C,
                h=stacker.z, rounding = corner, irounding = icorner);
        }
	}
}

module pcb(showbox) {
    volume1 = showbox ? pcb_box : pcb;
    move(pcb_center) {
        if($preview) color_this("green") cuboid(volume1, anchor = BOT);
    }
}

module window() {
    /*  ******************* IMPORTANT ********************
        This part must be printed with transparent filament. 
        Use 4 perimeters, ZERO infill, ZERO bottom layers
        and 4 top layers with a rectilinear top fill pattern.
    */
    cuboid (led2 + [2, 2, pcb_lift - floor], anchor = BOT);
    up (led2.z + pcb_lift - floor) 
        cuboid (led2 - [0.1, 0.1, 0], rounding = 1, edges = "Z", anchor = BOT);
}


module echo2(arg) {
	echo(str("\n\n", arg, "\n\n" ));
}