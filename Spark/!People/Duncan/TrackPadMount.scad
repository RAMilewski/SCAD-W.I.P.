include <BOSL2/std.scad>
$VPD=300;

// Trackpad Settings
TRACKPAD_WIDTH = 160;
TRACKPAD_DEPTH = 115;
TRACKPAD_CORNER_RADIUS = 10;
TRACKPAD_WALL_THICKNESS = 2;
TRACKPAD_FRAME_FRONT_HEIGHT = 5;
TRACKPAD_FRAME_REAR_HEIGHT = 11;
TRACKPAD_CHARGING_PORT_WIDTH = 10;
TRACKPAD_CHARGING_PORT_HEIGHT = 6;
TRACKPAD_POWER_SWITCH_PORT_WIDTH = 20;
TRACKPAD_POWER_SWITCH_PORT_HEIGHT = TRACKPAD_FRAME_REAR_HEIGHT / 1.5;
TRACKPAD_POWER_SWITCH_PORT_DEPTH = 10;
FOOTPAD_SUPPORT_WIDTH = 12;
FOOTPAD_SUPPORT_LENGTH = 12; 
FOOTPAD_SUPPORT_HEIGHT = 2;
PORT_ROUNDING_RADIUS = 2;

// Keyboard Strut settings
STRUT_LENGTH = 131;
STRUT_WIDTH = 20;
STRUT_BATTERY_CHANNEL_WIDTH = 25;
STRUT_HEIGHT = 5;
STRUT_TINE_HEIGHT = 5;
STRUT_TINE_THICKNESS = 5;
STRUT_ROUNDING = 1;
STRUT_SEPARATION = 70;
STRUT_CROSSBRACE_DEPTH = 80;
STRUT_CROSSBRACE_HEIGHT = STRUT_HEIGHT / 1.5;

/* [Hidden] */

$fn = 100;
BOOLEAN_EPS = 1;
SLOP = 0.1;

module trackpad_outer_solid(height) {
    linear_extrude(height=height)
        offset(r=TRACKPAD_CORNER_RADIUS)
            square(
                [
                    TRACKPAD_WIDTH - (TRACKPAD_CORNER_RADIUS * 2),
                    TRACKPAD_DEPTH - (TRACKPAD_CORNER_RADIUS * 2)
                ],
                center=true
            );
}

module trackpad_outer_inverse(height) {
    difference() {
        translate([0, 0, -BOOLEAN_EPS / 2])
            cuboid(
                [
                    TRACKPAD_WIDTH + BOOLEAN_EPS,
                    TRACKPAD_DEPTH + BOOLEAN_EPS,
                    height + BOOLEAN_EPS
                ],
                anchor=BOT
            );

        translate([0, 0, -BOOLEAN_EPS / 2])
        trackpad_outer_solid(height + BOOLEAN_EPS);
    }
}

module trackpad_notch_fillet(position, z_adjust, rotation) {
    translate(position + [0, 0, z_adjust])
    rotate(rotation)
    linear_extrude(height = TRACKPAD_WALL_THICKNESS + SLOP * 2, v = [0, 0, 1])
    difference() {
        square([PORT_ROUNDING_RADIUS, PORT_ROUNDING_RADIUS]);
        translate([PORT_ROUNDING_RADIUS, PORT_ROUNDING_RADIUS])
        circle(r = PORT_ROUNDING_RADIUS, $fn = $fn);
    }
}

// --- Main Assembly ---
union() {
    // Trackpad frame with port notches
    diff("cutout") {
        union() {
            // 1. Trackpad Frame
            difference() {
                rect_tube(
                    size=[TRACKPAD_WIDTH, TRACKPAD_DEPTH], 
                    wall=TRACKPAD_WALL_THICKNESS, 
                    h=TRACKPAD_FRAME_REAR_HEIGHT,
                    rounding=TRACKPAD_CORNER_RADIUS,
                    anchor=BOT
                );

                // Right-edge power switch cut-out fillet.
                trackpad_notch_fillet(
                    position = [
                        TRACKPAD_WIDTH / 2 + SLOP,
                        TRACKPAD_DEPTH / 2 - TRACKPAD_POWER_SWITCH_PORT_DEPTH,
                        TRACKPAD_FRAME_REAR_HEIGHT
                    ],
                    z_adjust = -0.53,
                    rotation = [90, 90, -90]
                );
                // Rear-edge power switch cut-out fillet.
                trackpad_notch_fillet(
                    position = [
                        TRACKPAD_WIDTH / 2 + SLOP - TRACKPAD_POWER_SWITCH_PORT_WIDTH,
                        TRACKPAD_DEPTH / 2 - TRACKPAD_WALL_THICKNESS - SLOP,
                        TRACKPAD_FRAME_REAR_HEIGHT
                    ],
                    z_adjust = 0,
                    rotation = [180, 90, -90]
                );
            }

            // 2. Corner Supports
            difference() {
                union() {
                    for (x_dir = [-1, 1], y_dir = [-1, 1]) {
                        translate(
                            [
                                x_dir * ((TRACKPAD_WIDTH / 2) - TRACKPAD_WALL_THICKNESS),
                                y_dir * ((TRACKPAD_DEPTH / 2) - TRACKPAD_WALL_THICKNESS),
                                0
                            ]
                        )
                        translate(
                            x_dir > 0 ?
                                [-FOOTPAD_SUPPORT_WIDTH / 2, (y_dir > 0 ? 0 : FOOTPAD_SUPPORT_LENGTH), 0] :
                                [FOOTPAD_SUPPORT_WIDTH / 2, (y_dir > 0 ? 0 : FOOTPAD_SUPPORT_LENGTH), 0]
                        )

                        cuboid(
                            [FOOTPAD_SUPPORT_WIDTH, FOOTPAD_SUPPORT_LENGTH, FOOTPAD_SUPPORT_HEIGHT], 
                            rounding=STRUT_ROUNDING,
                            edges="Z",
                            anchor=BOT+BACK,
                            except=[
                                (y_dir > 0 ? BACK : FRONT) + (x_dir > 0 ? LEFT : RIGHT),
                                (y_dir > 0 ? FRONT : BACK) + (x_dir > 0 ? RIGHT : LEFT)
                            ],
                        );
                    }
                }

                trackpad_outer_inverse(FOOTPAD_SUPPORT_HEIGHT);
            }
        }

        // 3. Slope wedge: front edge lower than rear edge
        tag("cutout") hull() {
            up(TRACKPAD_FRAME_FRONT_HEIGHT)
            fwd((TRACKPAD_DEPTH / 2) + 0.2)
            cuboid(
                [TRACKPAD_WIDTH * 1.1, 0.3, TRACKPAD_FRAME_REAR_HEIGHT],
                anchor=BOT+FRONT
            );

            up(TRACKPAD_FRAME_REAR_HEIGHT)
            back((TRACKPAD_DEPTH / 2) + 0.2)
            cuboid(
                [TRACKPAD_WIDTH * 1.1, 0.3, TRACKPAD_FRAME_REAR_HEIGHT],
                anchor=BOT+BACK
            );
        }

        // 4. Trackpad frame notches
        tag("cutout") back(TRACKPAD_DEPTH / 2) {
            // Power-switch cut-out
            right(TRACKPAD_WIDTH / 2)
            up(TRACKPAD_FRAME_REAR_HEIGHT)
            cuboid(
                [
                    TRACKPAD_POWER_SWITCH_PORT_WIDTH,
                    (TRACKPAD_POWER_SWITCH_PORT_DEPTH * 2) + SLOP,
                    TRACKPAD_POWER_SWITCH_PORT_HEIGHT
                ],
                anchor=TOP+RIGHT,
                rounding=PORT_ROUNDING_RADIUS,
                except=[BACK, RIGHT, TOP]
            );

            // Charging port cut-out
            up(TRACKPAD_FRAME_REAR_HEIGHT / 2)
            cuboid(
                [
                    TRACKPAD_CHARGING_PORT_WIDTH,
                    (TRACKPAD_WALL_THICKNESS * 2) + SLOP,
                    TRACKPAD_CHARGING_PORT_HEIGHT
                ],
                anchor=CENTER,
                rounding=PORT_ROUNDING_RADIUS,
                except=[FRONT, BACK]
            );
        }
    }

    // 5. Struts and Rear Fork Assembly (not affected by port notches)
    back(TRACKPAD_DEPTH / 2) {
        for (x = [-STRUT_SEPARATION / 2, STRUT_SEPARATION / 2]) {
            translate([x, 0, 0]) {
                // Strut body
                cuboid(
                    [STRUT_WIDTH, STRUT_LENGTH, STRUT_HEIGHT],
                    anchor=FRONT+BOT,
                    rounding=STRUT_ROUNDING,
                    except=[FRONT, BACK]
                );

                translate([0, STRUT_LENGTH, 0]) {
                    // Far rear tine
                    translate([0, 0, 0])
                    cuboid(
                        [STRUT_WIDTH, STRUT_TINE_THICKNESS, STRUT_TINE_HEIGHT + STRUT_HEIGHT],
                        rounding=STRUT_ROUNDING,
                        anchor=BOT
                    );

                    // Near tine
                    translate([0, -STRUT_BATTERY_CHANNEL_WIDTH, 0])
                    cuboid(
                        [STRUT_WIDTH, STRUT_TINE_THICKNESS, STRUT_TINE_HEIGHT + STRUT_HEIGHT],
                        rounding=2,
                        anchor=BOT
                    );
                }
            }
        }

        // 6. Crossbrace between the two struts.
        back(STRUT_CROSSBRACE_DEPTH)
        cuboid(
            [STRUT_SEPARATION - STRUT_WIDTH / 2, 10, STRUT_CROSSBRACE_HEIGHT],
            anchor=FRONT+BOT,
            rounding=STRUT_ROUNDING
        );
    }
}


//back(TRACKPAD_DEPTH/2) zrot(90) ruler();