include <BOSL2/std.scad>
$VPD = 300;

/* [Trackpad Settings] */
TRACKPAD = [160,115,11];
TRACKPAD_CORNER_RADIUS = 10;
TRACKPAD_WALL_THICKNESS = 2;
TRACKPAD_FRAME_FRONT_HEIGHT = 5;
TRACKPAD_CHARGING_PORT = [10,TRACKPAD_WALL_THICKNESS,6];
TRACKPAD_POWER_SWITCH_PORT = [21,11,TRACKPAD.z / 1.5];
FOOTPAD_SUPPORT = [12,12,2];
PORT_ROUNDING_RADIUS = 2;

/* [Keyboard Strut settings] */
STRUT = [20,131,5];
STRUT_TINE = [STRUT.x,5,5];
STRUT_ROUNDING = 1;
STRUT_BATTERY_CHANNEL_WIDTH = 25;
STRUT_SEPARATION = 70;
STRUT_CROSSBRACE = [STRUT_SEPARATION, 10, STRUT.z / 1.5]; // Extends into struts to avoid rounding issues.
STRUT_CROSSBRACE_OFFSET = 20;

/* [Hidden] */

$fn = 72;

// Main
frame()
    position(BACK+BOT) struts(anchor = FWD+BOT);

// Trackpad frame with port notches
module frame(anchor = CENTER, spin=0, orient=UP) {
    attachable(anchor, spin, orient, size = TRACKPAD) {
        union() {
        // 1. Trackpad Frame
            diff() {
                rect_tube(size=[TRACKPAD.x, TRACKPAD.y], h=TRACKPAD.z, wall=TRACKPAD_WALL_THICKNESS, rounding=TRACKPAD_CORNER_RADIUS, anchor = CENTER);

        // 2. Corner Supports
                grid_copies(n = [2,2], spacing = [TRACKPAD.x - FOOTPAD_SUPPORT.x, TRACKPAD.y - FOOTPAD_SUPPORT.y]) {
                    position(BOT) cuboid(FOOTPAD_SUPPORT, rounding = PORT_ROUNDING_RADIUS, edges = "Z", anchor = BOT)
                        edge_mask([$col * 2 - 1, $row * 2 - 1, 0])
                            rounding_edge_mask(l=$parent_size.z+0.01, r=TRACKPAD_CORNER_RADIUS);      //edge mask has implied "remove" tag
                }
        // 3. Trackpad Power Switch Port    
                position(BACK+RIGHT+TOP) move([1,1,0]) tag("remove")
                    rounded_prism(rect([TRACKPAD_POWER_SWITCH_PORT.x, TRACKPAD_POWER_SWITCH_PORT.y]), height = TRACKPAD_POWER_SWITCH_PORT.z,
                        k = 0.93, joint_bot = PORT_ROUNDING_RADIUS, joint_top = -PORT_ROUNDING_RADIUS, joint_sides = 0.01, anchor = TOP+RIGHT+BACK);

        // 4. Trackpad Charging Port
                position(BACK) tag("remove")
                    cuboid(TRACKPAD_CHARGING_PORT, rounding = PORT_ROUNDING_RADIUS, edges = "Y", anchor = BACK);

        // 5.  Profiling Wedge
                position(TOP) yrot(180) tag("remove")
                wedge(TRACKPAD-[0,0,TRACKPAD_FRAME_FRONT_HEIGHT], anchor = BOT);
            }
        }
        children();
    }
}

// 6. Struts and Rear Fork Assembly
module struts(anchor = CENTER, spin=0, orient=UP) {
    attachable(anchor, spin, orient, size = [STRUT_SEPARATION + 1 * STRUT.x, STRUT.y, STRUT.z]){
        union() {
            xcopies(n = 2, spacing = STRUT_SEPARATION) {     
                // Strut body
                cuboid(STRUT, rounding=STRUT_ROUNDING, except=[FRONT, TOP]) {
                        // Far rear tine
                        align(TOP,BACK) 
                            cuboid(STRUT_TINE, rounding=STRUT_ROUNDING, except=BOT);
                        // Near tine
                        align(TOP,BACK) fwd(STRUT_BATTERY_CHANNEL_WIDTH)
                            cuboid(STRUT_TINE, rounding=STRUT_ROUNDING, except=BOT);
                    }
                }
                // Crossbrace between the two struts.        
                position(BOT) back(STRUT_CROSSBRACE_OFFSET)
                    cuboid(STRUT_CROSSBRACE, rounding=STRUT_ROUNDING, except = [LEFT,RIGHT], anchor = BOT);
        }
        children();
    }
}
