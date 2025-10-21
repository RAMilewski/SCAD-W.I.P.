include <BOSL2/std.scad>

multiplier = 2;     //[2,2.4142]
handle = 70;
wye = 40;
calibration = -0.33;    // Adjust to zero out error.  Printer, nozzle size, and filament dependant. 

/* [Hidden] */
arm = [wye,20,8];    //the two arms of the Y
mount = [handle,30,8];  //the part that holds the caliper
groove = [mount.x - 5,16,4]; //groove.y = the width of the caliper 
well = [12,16,6];   //clearance well for the caliper probe retainer
gap = [4,4,5];      //gap for the caliper probe
edge = 1;           //edge rounding radius
$fn = 72;           //keep the rounding smooth



theta =  asin(multiplier/(multiplier+1));

function pivot(index) = (index == 0) ? LEFT+BACK : LEFT+FWD; 

diff() {
    cuboid(mount, rounding = edge, anchor = RIGHT) {   
        position(TOP+LEFT) tag("remove") cuboid(groove, anchor = TOP+LEFT); 

        position(TOP+RIGHT) left(calibration) tag("remove") #cuboid(well, anchor = TOP+RIGHT){  // }
            position([RIGHT+BACK,RIGHT+FWD]) tag("remove") #cyl(h = well.z, d = 2);             // } -- This block moves by calibration amount   
            position(TOP+RIGHT) tag("remove") cuboid(gap, anchor = TOP);                        // }
        }
        position(RIGHT) zrot_copies([-theta,theta]) cuboid(arm, rounding = edge, anchor = pivot($idx)); 
    }
}

