//  Spark Studio
//  Tube fittings for lighted M sign from 20mm tubes.
//  by Richard
//

/*######################################################/*

    CONFIGURATION

/*######################################################*/

include <BOSL2/std.scad>

/* [Select Part to Render] */
part = "all";       //  [all,elbow,neck,mount,half,clip]

/* [ Tube Dimensions ] */
//Adjust tube_id to compensate for over/under extrusion
tube_id = 16.85;    //  Tube id            
tube_wall = 2.6;    //  Tube wall 

insert_wall = 2;    // Insert wall 
insert_h = 10;      // Length of insert
neck_h = 7;         // Length of neck 

/* [Elbow] */
angle = 90;         //  [30,60,90]
// Elbow radius of curvature
elbow_r = 0;       
flat = true;        //  [true,false]    

/* [Pin] */
add_pin = true;         //  [true,false]
pin_d = 2;          // LED strip routing pin

/* [Mounting Tab] */
add_tab = true;       //  [true,false]    
hole = 4;           // Mounting hole diameter


/* [LED Backing Card Thickness] */
card  = 1.5;        // LED backing card thickness

/* [Y Position of Slice Plane] */
slice_y = 0;        // Y position of slice plane


/* [Hidden] */
$fn=72;
eps = 0.1;

tube_od = tube_id + 2 * tube_wall;    //  Tube od  
tube_ir = tube_id/2;     //  Tube internal radius

insert_id = tube_id - insert_wall * 2;  //  Insert id

tab = [hole * 2 , 2, tube_od/2];      //  Mounting Tab  

clip_block = [tube_od + 20, 10, tube_od];    //size of mounting clip
clip_lift = 10;                              //mounting clip base lift  
clip_hole = 2.5;
clip_head = [5.5,undef,3];

chord_l = 2 * elbow_r * sin((180-angle)/2);      //Reposition parts when 
chord_h = (elbow_r) * (1 - cos((180-angle)/2));  //elbow_r > 0

/*####################### MAIN ###############################*/

if (part == "all")   M_tube_fitting(angle);
if (part == "elbow") elbow(angle);
if (part == "neck")  neck();
if (part == "mount")   tab();
if (part == "clip")  clip(); 
if (part == "half")  front_half(y = slice_y) M_tube_fitting(angle);


/*#########################  Modules #############################*/

module M_tube_fitting (angle) {
    diff() {
        elbow(angle);
        if (flat) tag("remove")  cyl(d = 20, h = tube_wall - 1.5, anchor = BOT);   // Flatten Bottom        
    }
    xflip_copy() {  //place neck at each end of elbow
        up(tube_od + chord_h - (sin(angle/2) * tube_od/2)) right(chord_l/2 + cos(angle/2) * tube_od/2) yrot(angle/2) neck();
    }

    if (add_pin)  up(tube_od/2) ycyl(d = pin_d, h = tube_id);      //LED strip routing pin

    if (add_tab) fwd(tube_od/2 - tab.y)  up(tube_od * 0.75) tab();  //Mounting tab w/screw hole
}

module elbow(angle) {
    region = [ circle(d = tube_od), circle(d = insert_id) ]; 
    
    transforms = [ 
        for (a=[0: 5 : 180 - angle]) yrot(a, cp=[tube_od/2 + elbow_r ,0 ,0]), 
    ];

    left(tube_od/2 - chord_l/2) up(tube_od + chord_h)       // Reposition to place bottom center 
        yrot(180 + angle/2, cp = [tube_od/2, 0, 0])         // of the elbow at the origin after the sweep.
  
    sweep(region, transforms, closed=false, caps=true);     
    
    //  up(tube_od + chord_h) xrot(-90) ruler(anchor = BACK);    //uncomment to show ruler
}


module neck() {
    tag_scope("neck")
    diff() {
        tube(od = tube_od, id = insert_id, h = neck_h, anchor = BOT) {                      //Tube neck
            attach(TOP) tube(od = tube_id, id = insert_id, h = insert_h, anchor = BOT)      //Tube insert
                tag("remove") attach(TOP) prismoid([tube_id, card], [tube_id, card * 2], insert_h, anchor = TOP);  //Card alignment slots
        }
    }
}

module tab() {  // Mounting tab
    tag_scope("tab")
    diff() {
        conv_hull() {
            xscale(3) #ycyl(d = tab.x, h = tab.y, rounding1 = tab.y/2, anchor = BACK);
            up(tube_od/2) #ycyl(d = tab.x, h = tab.y, anchor = BACK);
        }
        up(tube_od/2) tag("remove") ycyl(d = hole, h = tab.y, rounding2 = -tab.y/2, anchor = BACK);
    }
}

module clip(){
    difference() {
        cuboid(clip_block, rounding = 3, except = BOT);
        up(clip_lift) left(tube_od/2) cuboid([5,clip_block.y + eps,10], anchor = LEFT);
        up (tube_od * 0.25) {
            ycyl(d = tube_od + 0.5, h = 10 + eps);
            xcyl(d = clip_hole, h = tube_od, anchor = RIGHT);
            left(clip_block.x/2 - clip_head.z/2) xcyl(d = clip_head.x, h = clip_head.z);
        }
        cyl(d = hole, h = tube_od, anchor = TOP);
        down(clip_lift/2) cyl(d = hole + 2, h = clip_head.z, anchor = TOP);
        
    }
}