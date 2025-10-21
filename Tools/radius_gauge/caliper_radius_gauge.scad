// radius gauge attachment for calipers - https://www.printables.com/model/122532-improved-radius-gauge-for-calipers
//inspired by https://www.prusaprinters.org/prints/14474-radius-gauge-for-calipers

// note: my calipers are very cheap, change the fitment settings to suit your own (appears mostly universal so feel free to try this first)

// radius of measured object = 
//    caliper measurement * sin(interior_angle) / (1-sin(interior_angle))



/* [Important] */

// the angle in the interior arms that determines the equation used to get the final measurement (see the bottomside label). Smaller values give longer arms but more precision and easier measurements.
interior_angle=30; //[11.5370, 19.4712, 30, 41.8103, 45, 48.5904]
// respectively: D=d/2, D=d, r=d, r=2*d, r=(sqrt(2)+q)*d  using a smaller number will increase the arm length considerably, but increase simplicity/speed of use and measurement precision. You can set this to any angle and the measurement multiplier will be displayed in the console output.

// maximum measurable radius (specifies arm length, calculated arm length shown in console output)
maximum_radius=40;



/* [Strength and Rigidity] */

// the length up the caliper the gauge will sit, make sure it is long enough to stay sturdy
caliper_support_length=60;
// total thickness of the model
total_thickness=10; //[0:0.1:20]
// side wall thickness of the section surrounding the caliper
caliper_side_wall=2; //[0:0.1:10]
// width of the arms
arm_width=10; //[0:0.1:40]
// extends the wall in the V of the arms to help with flex
minimum_radius=0; //[0:0.1:30]



/* [Fitment] */

// largest width of the caliper arm
caliper_width=16; //[0:0.1:30]
// largest thickness of the caliper arm
caliper_thickness=3.6; //[0:0.1:10]
// width of the caliper sliding arm
caliper_slide_width=3.8; //[0:0.1:10]
// thickness of the caliper sliding arm
caliper_slide_thickness=2; //[0:0.1:10]
// width of the end tip of the caliper sliding arm
caliper_slide_tip_width=2; //[0:0.1:10]
// width of the plate holding the caliper together
caliper_plate_width=7; //[0:0.1:20]
// depth of the plate holding the caliper together
caliper_plate_depth=2; //[0:0.1:10]



/* [Clips for Caliper] */
// enable if you would like to clip the caliper into the gauge, rather than sit it in place
clips=true;
// Z height of the caliper clips. Adjust such that the overhang angle is printable (check console output)
clip_height=0.8;
// Y width of the caliper clips
clip_width=0.5;
// length of the clip
clip_length=15;
// provide a gap either side of the clip to enable it to flex
clip_seperation_gap=0.5;
// wall thickness of the clips
clip_thickness=0.86;



/* [Hole for Magnet] */
// enable if you would like to add an interior hole for a magnet
magnet=false;
number_of_magnets=2;
magnet_shape="cube"; //["cube", "cylinder"]
// applies to both cylinder and cube. Ensure total_thickness is enough to encompass magnet
magnet_thickness=2; //[0:0.1:10]
// applies if cylinder
magnet_diameter=14; //[0:0.1:50]
// applies if cube
magnet_width=10; //[0:0.1:50]
// applies if cube
magnet_length=20; //[0:0.1:50]
// applies if number of magnets > 1
magnet_spacing=2; //[0:0.1:20]
// turn off before rendering
preview_magnet=false;




/* [Embedded Label for Measurement Equation] */
enable_label=true;
font_style="osifont";
font_size=6; //[0:0.1:30]
font_depth=0.6; //[0:0.1:3]
decimal_places=3; //[5]


/* [Aesthetic] */

// add fillets to the corners of the model
XY_fillet_radius=1.5; //[0:0.1:10]



/* [Resolution] */
$fn=50; //[200]
tolerance=0.15; //[0:0.01:1]
clearance=0.4; //[0:0.1:2]



/* [Hidden] */

// Derived values

// width of the model around the caliper section
total_width_caliper=caliper_width+2*tolerance+2*caliper_side_wall;

// offset the caliper slightly such that the tip of the slide is centered in the arms
caliper_slide_exit_offset=caliper_slide_tip_width/2 - caliper_slide_width/2;
echo(caliper_slide_exit_offset=caliper_slide_exit_offset);

// check the lengths of the arms
arm_length=maximum_radius/tan(interior_angle);
echo(arm_length=arm_length);

// check the overhang of the clips (shouldn't be a big deal on most printers)
clip_overhang_angle=90-atan(clip_height/2/clip_width);
echo(clip_overhang_angle=clip_overhang_angle);

// amount to move magnet across
magnet_x=magnet_spacing + (magnet_shape=="cylinder" ? magnet_diameter : magnet_length);

// amount to multiply the measured value by to get the radius
measurement_multiplier=((interior_angle<30) ? 2 : 1)*sin(interior_angle) / (1-sin(interior_angle));
echo(measurement_multiplier=measurement_multiplier);
label_string=str((interior_angle<30) ? "D = " : "r = ", abs(measurement_multiplier-1) < 0.001 ? "" : round(measurement_multiplier*10^decimal_places)/10^decimal_places, "d");



// draw object
if (preview_magnet==false)
{
    radius_gauge();
}
else
{
    %radius_gauge();
    magnet();
}

// MAIN
module radius_gauge()
{
    difference()
    {
        
        //main body
        linear_extrude(total_thickness, convexity=2)
        offset(r = -XY_fillet_radius)
        offset(r = 2*XY_fillet_radius)
        offset(r = -XY_fillet_radius)
        union()
        {
            translate([0, -total_width_caliper/2])
            square([caliper_support_length, total_width_caliper]);
            
            //arms
            rotate([0,0,180])
            translate([0,-caliper_slide_exit_offset])
            mirror_offset(v=[0,1,0], duplicate=true)
            rotate([0,0,interior_angle])
            square([arm_length+XY_fillet_radius, arm_width]);
            
            intersection()
            {
                rotate([0,0,180])
                translate([0,-caliper_slide_exit_offset])
                mirror_offset(v=[0,1,0], duplicate=true)
                rotate([0,0,interior_angle])
                translate([-arm_length,0,0])
                square([arm_length, arm_width]);
                
                translate([0, -total_width_caliper/2])
                square([caliper_support_length, total_width_caliper]);
            }
            
        }
        
        //main caliper slot
        translate([0, -(caliper_width+2*tolerance)/2, total_thickness-(caliper_thickness+clip_height+tolerance)])
        cube([caliper_support_length+1, caliper_width+2*tolerance, caliper_thickness+clip_height+1]);
        
        //caliper plate clearance divet
        translate([0, -(caliper_width+2*tolerance)/2, total_thickness-(caliper_thickness+clip_height+tolerance)-(caliper_plate_depth+clip_height+clearance)])
        cube([caliper_plate_width+clearance, caliper_width+2*tolerance, caliper_plate_depth+clip_height+1]);
        
        //caliper slide clearance divet
        translate([-10, -(caliper_slide_width+clearance)/2, total_thickness-(caliper_slide_thickness+clip_height+clearance)])
        cube([11, caliper_slide_width+clearance, caliper_slide_thickness+clip_height+1]);
        
        //equation label
        if (enable_label==true)
        {
            translate([caliper_support_length/2,0,-1])
            linear_extrude(font_depth+1,convexity=2)
            rotate([180,0,180])
            text(label_string, font=font_style, size=font_size, halign="center", valign="center");
        }
        
        // clip mechanisms
        if (clips==true)
        {
            // clip seperation gaps
            mirror_offset(v=[0,1,0], duplicate=true)
            mirror_offset(v=[1,0,0], p=[caliper_support_length/2,0,0], duplicate=true)
            translate([caliper_support_length/2+clip_length/2, -total_width_caliper/2-1,total_thickness-(caliper_thickness+clip_height+tolerance)])
            cube([clip_seperation_gap, caliper_side_wall+2, caliper_thickness+clip_height+1]);
            
            // thin clip walls
            mirror_offset(v=[0,1,0], duplicate=true)
            translate([caliper_support_length/2, total_width_caliper/2, total_thickness-(caliper_thickness+clip_height+tolerance)+total_thickness/2])
            difference()
            {
                cube([clip_length+clip_seperation_gap, 2*(caliper_side_wall-clip_thickness), total_thickness], center=true);
                
                translate([-(clip_length+clip_seperation_gap+2)/2,0, -total_thickness/2])
                rotate([45,0,0])
                mirror([0,1,0])
                cube([clip_length+clip_seperation_gap+2,10,10]);
            }
        }
        
        //magnet hole
        if (magnet==true)
        {
            magnet();
            echo(magnet_depth=(total_thickness-(caliper_thickness+clip_height))/2-(magnet_thickness+tolerance)/2);
            echo(PAUSE_AT_Z_HEIGHT=(total_thickness-(caliper_thickness+clip_height))/2+(magnet_thickness+tolerance)/2);
        }
    }

    //thicken extra wall determined by minimum_radius
    translate([-minimum_radius, -caliper_width/2+caliper_slide_exit_offset, 0])
    cube([minimum_radius,caliper_width,total_thickness-(caliper_slide_thickness+clip_height+clearance)]);

    //slot mechanism clips
    if (clips == true)
    {
        mirror_offset(v=[0,1,0], duplicate=true)
        translate([caliper_support_length/2,-(caliper_width+2*tolerance)/2,total_thickness-clip_height/2])
        rotate([0,90,0])
        linear_extrude(clip_length, center=true)
        polygon([ [0,0], [clip_height/2,0], [0,clip_width], [-clip_height/2,0] ]);
    }
}

module magnet()
{
    translate([caliper_support_length/2-(number_of_magnets-1)*magnet_x/2, 0, (total_thickness-(caliper_thickness+clip_height))/2])
    for (i=[1:number_of_magnets])
    {
        translate([(i-1)*magnet_x,0,0])
        if (magnet_shape=="cylinder")
        {
            cylinder(h=magnet_thickness+tolerance, d=magnet_diameter+tolerance, center=true);
        }
        else
        {
            cube([magnet_length, magnet_width, magnet_thickness]+tolerance*[1,1,1], center=true);
        }
    }
}


module mirror_offset(v, p=[0,0,0], duplicate=false)
{
    
    mirror(v)
    translate(-2*p)
    children();
    
    if(duplicate){ children(); }
    
}
