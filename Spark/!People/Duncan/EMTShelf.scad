include <BOSL2/std.scad>

/* 
 * Elevated Magic Trackpad Shelf & MX Keys Mini Lap Cradle
 * Monolithic Design Optimized for Prusa Mini (180 x 180 x 180 mm) Print Bed & Heavy-Duty One-Handed Lifting
 *
 * Render commands:
 * openscad -o spike_iso.png --imgsize=1200,900 --projection=p --camera=-35,-75,45,60,0,32,620 elevated_shelf_spike.scad
 * openscad -o spike_tilted_mini.png --imgsize=1200,900 --projection=p --camera=20,-20,80,45,0,35,420 -D 'MODE="single_piece_diagonal"' -D 'SHOW_BED_BOUNDS=true' elevated_shelf_spike.scad
 * openscad -o spike_side.png --imgsize=1200,900 --projection=o --camera=0,30,20,90,0,-90,450 elevated_shelf_spike.scad
 * openscad -o spike_tray_top.png --imgsize=1200,900 --projection=p --camera=40,54,57,60,0,40,230 elevated_shelf_spike.scad
 */

/* [Display Mode] */
MODE = "cradle_only"; // [assembled:Full Monolithic Assembly, single_piece_diagonal:Tilted 3D Monolithic Print (Fits Prusa Mini 180x180x180mm), cradle_only:Keyboard Cradle Only, shelf_only:Elevated Shelf Only]

/* [Prusa Mini Build Volume Check] */
SHOW_BED_BOUNDS = false;        // Show translucent 180x180x180mm Prusa Mini build volume
BED_X = 180.0;
BED_Y = 180.0;
BED_Z = 180.0;

/* [Keyboard Dimensions (Logitech MX Keys Mini)] */
KB_WIDTH = 296.0;
KB_DEPTH = 132.0;
KB_FRONT_THICKNESS = 6.5;
KB_REAR_THICKNESS = 20.5;
KB_BATTERY_BAR_DEPTH = 25.0;     // Front-to-back depth of rear battery wedge
KB_BATTERY_BAR_HEIGHT = 16.0;    // Height of rear battery bar above desk

/* [Trackpad Dimensions (Apple Magic Trackpad 2/3)] */
TP_WALL_THICKNESS = 3.5;
TP_WIDTH = 160.5;
TP_DEPTH = 115.5;
TP_FRONT_H = 5.0;
TP_REAR_H = 11.5;
TP_CORNER_R = 9.0;
TP_PORT_WIDTH = 14.0;
TP_PORT_HEIGHT = 7.5;
TP_SWITCH_WIDTH = 24.0;         // Clean, wide power switch access cutout
TP_SWITCH_HEIGHT = 12.0;

/* [Elevated Shelf Geometry] */
SHELF_ELEVATION_Z = 36.0;       // Vertical rise of trackpad shelf above keyboard battery bar
SHELF_SETBACK_Y = 16.0;         // Setback behind keyboard rear edge
SHELF_TILT_ANGLE = 6.0;         // Ergonomic forward tilt angle (degrees)
SHELF_FLOOR_THICKNESS = 2.5;

/* [Lap Runner & Strut Geometry] */
RUNNER_WIDTH = 26.0;
RUNNER_THICKNESS = 5.0;
STRUT_SPACING = 114.0;          // Spacing between left and right lap runners
CORNER_R = 2.0;                 // Consistent global fillet/rounding radius

/* [Keyboard Retention Hardware Settings] */
FRONT_LIP_WALL = 5.0;
FRONT_LIP_HEIGHT = 10.0;        // Low-profile front stop hooking front edge
FRONT_CATCH_DEPTH = 3.0;        // Small overhang catch tab at top of front lip

REAR_JAW_WALL = 12.0;           // Solid, thick structural rear wall for high strength
REAR_JAW_TOP_THICKNESS = 5.0;   // Beefy top clamping jaw
REAR_JAW_OVERHANG = 8.0;        // Forward overhang retaining top of battery bar
REAR_JAW_HEIGHT = KB_BATTERY_BAR_HEIGHT + REAR_JAW_TOP_THICKNESS;

/* [Riser & Crossbrace Settings] */
RISER_THICKNESS = 10.0;         // Substantially thickened riser arms for zero flex
CROSSBRACE_WIDTH = 20.0;

/* [Tolerances & Quality] */
$fn = 72;

// ==========================================
// Top-Level Scene Selection
// ==========================================
if (MODE == "assembled") {
    // 100% Monolithic solid body (Continuous, no joints, max strength)
    monolithic_assembly();
    if (SHOW_BED_BOUNDS) prusa_mini_bounds();
} else if (MODE == "single_piece_diagonal") {
    // Monolithic print tilted diagonally to fit within 180x180x180mm Prusa Mini volume
    translate([0, 0, BED_Z / 2])
        zrot(45)
            xrot(-35)
                monolithic_assembly();
    if (SHOW_BED_BOUNDS) prusa_mini_bounds();
} else if (MODE == "cradle_only") {
    keyboard_lap_cradle();
    if (SHOW_BED_BOUNDS) prusa_mini_bounds();
} else if (MODE == "shelf_only") {
    trackpad_shelf_assembly();
    if (SHOW_BED_BOUNDS) prusa_mini_bounds();
}

module prusa_mini_bounds() {
    %translate([0, 0, BED_Z / 2])
        cube([BED_X, BED_Y, BED_Z], center = true);
}

// ==========================================
// Monolithic Unified Assembly (Single Piece)
// ==========================================
module monolithic_assembly() {
    union() {
        keyboard_lap_cradle();
        trackpad_shelf_assembly();
    }
}

// ==========================================
// Module: Seamless Keyboard Lap Base Skeleton
// ==========================================
module keyboard_lap_cradle() {
    front_y = -KB_DEPTH / 2;
    rear_y = KB_DEPTH / 2;

    union() {
        // Continuous lap runners with monolithic front J-hooks
        xcopies(spacing = STRUT_SPACING, n = 2) {
            single_monolithic_runner();
        }

        // Front crossbrace linking the runners
        translate([0, front_y + CROSSBRACE_WIDTH / 2 + 2, 0])
            cuboid([STRUT_SPACING + RUNNER_WIDTH, CROSSBRACE_WIDTH, RUNNER_THICKNESS], rounding = CORNER_R, except = [TOP], anchor = BOT);

        // Middle crossbrace across lap span
        translate([0, 0, 0])
            cuboid([STRUT_SPACING + RUNNER_WIDTH, CROSSBRACE_WIDTH * 0.85, RUNNER_THICKNESS], rounding = CORNER_R, except = [TOP], anchor = BOT);

        // Rear crossbrace anchoring the battery clamp and riser base
        translate([0, rear_y - KB_BATTERY_BAR_DEPTH / 2, 0])
            cuboid([STRUT_SPACING + RUNNER_WIDTH, KB_BATTERY_BAR_DEPTH, RUNNER_THICKNESS], rounding = CORNER_R, except = [TOP], anchor = BOT);

        // Integrated Rear Battery Clamp Jaws (2x)
        xcopies(spacing = STRUT_SPACING, n = 2) {
            translate([0, rear_y, 0])
                rear_battery_jaw();
        }
    }
}

module single_monolithic_runner() {
    front_y = -KB_DEPTH / 2;
    rear_y = KB_DEPTH / 2;
    total_len = (rear_y + REAR_JAW_WALL) - (front_y - FRONT_LIP_WALL);

    diff() {
        // 1. Full-length bottom runner rail with uniform bottom fillets
        translate([0, front_y - FRONT_LIP_WALL, 0])
            cuboid([RUNNER_WIDTH, total_len, RUNNER_THICKNESS], rounding = CORNER_R, except = [TOP], anchor = BOT+FRONT);

        // 2. Monolithic Front Upright Hook Block (continuous bottom-edge & top-edge fillets)
        translate([0, front_y - FRONT_LIP_WALL, 0])
            cuboid(
                [RUNNER_WIDTH, FRONT_LIP_WALL + FRONT_CATCH_DEPTH, FRONT_LIP_HEIGHT],
                rounding = CORNER_R,
                edges = [FRONT+BOT, LEFT+BOT, RIGHT+BOT, FRONT+TOP, BACK+TOP, LEFT+TOP, RIGHT+TOP],
                anchor = BOT+FRONT
            );

        // 3. Subtractive Pocket creating the clean internal retention slot for keyboard front bezel
        tag("remove")
            translate([0, front_y, RUNNER_THICKNESS])
                cuboid([RUNNER_WIDTH + 1, FRONT_CATCH_DEPTH + 1, FRONT_LIP_HEIGHT - RUNNER_THICKNESS - 2.0], rounding = 1.0, edges = "Y", anchor = BOT+FRONT);
    }
}

module rear_battery_jaw() {
    jaw_total_depth = REAR_JAW_WALL + REAR_JAW_OVERHANG;
    jaw_rise = REAR_JAW_HEIGHT - RUNNER_THICKNESS;

    diff() {
        // Upright clamp block rising from base runner with heavy structural rear support
        translate([0, (REAR_JAW_WALL - REAR_JAW_OVERHANG) / 2, RUNNER_THICKNESS + jaw_rise / 2])
            cuboid([RUNNER_WIDTH, jaw_total_depth, jaw_rise], rounding = CORNER_R, except = [BOT]);

        // Open front pocket for MX Keys Mini rear battery bar
        tag("remove")
            translate([0, -REAR_JAW_OVERHANG / 2 - 0.1, RUNNER_THICKNESS + (KB_BATTERY_BAR_HEIGHT - RUNNER_THICKNESS) / 2])
                cuboid([RUNNER_WIDTH + 1, REAR_JAW_OVERHANG + 0.2, KB_BATTERY_BAR_HEIGHT - RUNNER_THICKNESS + 0.1], rounding = 1.0, edges = "Y", anchor = CENTER);
    }
}

// ==========================================
// Module: Elevated Trackpad Shelf & Integrated Riser
// ==========================================
module trackpad_shelf_assembly() {
    rear_y = KB_DEPTH / 2;

    union() {
        // Integrated Monolithic Cantilever Riser Struts
        riser_struts();

        // Elevated Trackpad Tray positioned above & behind function keys
        translate([0, rear_y + SHELF_SETBACK_Y, SHELF_ELEVATION_Z])
            xrot(SHELF_TILT_ANGLE)
                trackpad_tray();
    }
}

module riser_struts() {
    union() {
        // Twin heavy-duty curved cantilever arms fused seamlessly into the rear jaw clamp
        xcopies(spacing = STRUT_SPACING, n = 2) {
            single_integrated_riser();
        }

        // Solid, continuous structural center crossbrace (no cutouts, maximizing torsional rigidity)
        backplate_center_z = (REAR_JAW_HEIGHT + SHELF_ELEVATION_Z - 2) / 2;
        backplate_center_y = KB_DEPTH / 2 + (REAR_JAW_WALL + SHELF_SETBACK_Y) / 2;
        backplate_h = (SHELF_ELEVATION_Z - REAR_JAW_HEIGHT) / cos(15);

        translate([0, backplate_center_y, backplate_center_z])
            xrot(15)
                cuboid([STRUT_SPACING + RUNNER_WIDTH, RISER_THICKNESS, backplate_h + 4], rounding = CORNER_R, anchor = CENTER);
    }
}

module single_integrated_riser() {
    // Seamless thick structural hull connecting the top and rear of the battery jaw to the shelf underside
    hull() {
        // Base connection: fully envelopes the thick top and back wall of the battery jaw
        translate([0, KB_DEPTH / 2 + (REAR_JAW_WALL - REAR_JAW_OVERHANG) / 2, REAR_JAW_HEIGHT - REAR_JAW_TOP_THICKNESS / 2])
            cuboid([RUNNER_WIDTH, REAR_JAW_WALL + REAR_JAW_OVERHANG, REAR_JAW_TOP_THICKNESS], rounding = CORNER_R, anchor = CENTER);

        // Upper connection: terminates cleanly against the underside of the trackpad tray (anchor = TOP)
        translate([0, KB_DEPTH / 2 + SHELF_SETBACK_Y, SHELF_ELEVATION_Z])
            xrot(SHELF_TILT_ANGLE)
                cuboid([RUNNER_WIDTH, 28, RISER_THICKNESS], rounding = CORNER_R, anchor = TOP);
    }
}

module trackpad_tray() {
    outer_w = TP_WIDTH + TP_WALL_THICKNESS * 2;
    outer_d = TP_DEPTH + TP_WALL_THICKNESS * 2;
    tray_h = TP_REAR_H + SHELF_FLOOR_THICKNESS;

    switch_center_x = TP_WIDTH / 2 - TP_SWITCH_WIDTH / 2 - 4;
    switch_r = 4.0; // Fillet radius for the waterfall round-over

    diff() {
        // 1. Main outer tray solid with uniform rounding
        cuboid([outer_w, outer_d, tray_h], rounding = TP_CORNER_R, except = [BOT], anchor = BOT);

        // 2. Trackpad Recessed Cavity (matches Magic Trackpad wedge profile)
        tag("remove")
            translate([0, 0, SHELF_FLOOR_THICKNESS])
                cuboid([TP_WIDTH, TP_DEPTH, tray_h + 2], rounding = TP_CORNER_R - 2, anchor = BOT);

        // 3. Low-profile Front Edge Scoop (comfortable for thumbs/palms)
        tag("remove")
            translate([0, -outer_d / 2, tray_h])
                cuboid([TP_WIDTH - 24, TP_WALL_THICKNESS * 2 + 2, TP_FRONT_H], rounding = CORNER_R, anchor = TOP);

        // 4. Rear Charging Port Cutout (Lightning / USB-C centered)
        tag("remove")
            translate([0, outer_d / 2, SHELF_FLOOR_THICKNESS + TP_PORT_HEIGHT / 2 + 1])
                cuboid([TP_PORT_WIDTH, TP_WALL_THICKNESS * 2 + 2, TP_PORT_HEIGHT], rounding = CORNER_R, edges = "Y", anchor = CENTER);

        // 5. Ergonomic Power Switch Cutout with Smooth Convex Top Round-Overs
        tag("remove") {
            // Main rectangular clearance slot
            translate([switch_center_x, outer_d / 2, SHELF_FLOOR_THICKNESS])
                cuboid([TP_SWITCH_WIDTH, TP_WALL_THICKNESS * 2 + 6, tray_h + 2], anchor = BOT);

            // Left top rim convex waterfall round-over
            translate([switch_center_x - TP_SWITCH_WIDTH / 2, outer_d / 2, tray_h])
                diff() {
                    cuboid([switch_r, TP_WALL_THICKNESS * 2 + 6, switch_r], anchor = RIGHT+TOP);
                    tag("remove")
                        xrot(90)
                            translate([-switch_r, -switch_r, 0])
                                cyl(r = switch_r, h = TP_WALL_THICKNESS * 2 + 8, anchor = CENTER);
                }

            // Right top rim convex waterfall round-over
            translate([switch_center_x + TP_SWITCH_WIDTH / 2, outer_d / 2, tray_h])
                diff() {
                    cuboid([switch_r, TP_WALL_THICKNESS * 2 + 6, switch_r], anchor = LEFT+TOP);
                    tag("remove")
                        xrot(90)
                            translate([switch_r, -switch_r, 0])
                                cyl(r = switch_r, h = TP_WALL_THICKNESS * 2 + 8, anchor = CENTER);
                }
        }

        // 6. Underside Rubber Foot Support Pads (4 corner rests for trackpad click mechanism)
        tag("keep")
            trackpad_corner_support_pads();

        // 7. Rear-facing Semicircular Finger Push Notch (accessed from open rear area)
        tag("remove")
            translate([0, 10, -0.5])
                intersection() {
                    cyl(d = 30, h = SHELF_FLOOR_THICKNESS + 2, anchor = BOT);
                    translate([0, 15, 0])
                        cuboid([32, 30, SHELF_FLOOR_THICKNESS + 4], anchor = BOT);
                }
    }
}

module trackpad_corner_support_pads() {
    pad_offset_x = TP_WIDTH / 2 - 14;
    pad_offset_y = TP_DEPTH / 2 - 14;
    xcopies(spacing = pad_offset_x * 2, n = 2) {
        ycopies(spacing = pad_offset_y * 2, n = 2) {
            translate([0, 0, SHELF_FLOOR_THICKNESS / 2])
                cyl(d = 16, h = SHELF_FLOOR_THICKNESS, anchor = CENTER);
        }
    }
}
