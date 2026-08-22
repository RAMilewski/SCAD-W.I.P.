include <BOSL2/std.scad>
use <mx_keys_mini.scad>
use <magic_trackpad.scad>

/* 
 * Elevated Magic Trackpad Shelf & MX Keys Mini Lap Cradle
 * Sloped Trackpad Tray Matching Magic Trackpad Wedge Angle (Glass Proud at All Points)
 *
 * Render commands:
 * openscad -o spike_iso.png --imgsize=1200,900 --projection=p --camera=-35,-75,45,60,0,32,620 elevated_shelf_spike.scad
 * openscad -o spike_side.png --imgsize=1200,900 --projection=o --camera=0,30,20,90,0,-90,450 elevated_shelf_spike.scad
 * openscad -o spike_tray_top.png --imgsize=1200,900 --projection=p --camera=40,54,57,60,0,40,230 elevated_shelf_spike.scad
 * openscad -o spike_tilted_mini.png --imgsize=1200,900 --projection=p --camera=20,-20,80,45,0,35,420 -D 'MODE="single_piece_diagonal"' -D 'SHOW_BED_BOUNDS=true' elevated_shelf_spike.scad
 */

/* [Display Mode] */
MODE = "assembled"; // [assembled:Full Monolithic Assembly, single_piece_diagonal:Tilted 3D Monolithic Print (Fits Prusa Mini 180x180x180mm), cradle_only:Keyboard Cradle Only, shelf_only:Elevated Shelf Only]

/* [Device Visualization] */
SHOW_DEVICES = true;            // Render imported MX Keys Mini and Magic Trackpad models for fit check

/* [Prusa Mini Build Volume Check] */
SHOW_BED_BOUNDS = false;        // Show translucent 180x180x180mm Prusa Mini build volume
BED_X = 180.0;
BED_Y = 180.0;
BED_Z = 180.0;

/* [Keyboard Dimensions (Logitech MX Keys Mini)] */
KB_WIDTH = 296.0;
KB_DEPTH = 132.0;
KB_FRONT_THICKNESS = 6.5;        // Front edge thickness of MX Keys Mini (~6.0-6.5mm)
KB_BATTERY_BAR_DEPTH = 26.0;     // Front-to-back depth of rear battery bar
KB_BATTERY_BAR_HEIGHT = 19.8;    // Snug height (~19.8mm above runner floor) with 1.0mm play for 18.8mm rear bar
KB_TILT_ANGLE = 5.5;             // Resting slope angle of MX Keys Mini deck (degrees)
KB_FIT_TOLERANCE = 1.5;          // Front-to-back length play (1.5mm) for easy drop-in

/* [Trackpad Dimensions (Apple Magic Trackpad 2/3)] */
TP_WALL_THICKNESS = 3.5;
TP_WIDTH = 160.5;
TP_DEPTH = 115.5;
TP_FRONT_H = 5.0;               // Front edge height of Magic Trackpad wedge
TP_REAR_H = 11.5;               // Rear edge height of Magic Trackpad wedge
TP_CORNER_R = 8.0;              // Corner radius of Magic Trackpad
TP_PORT_WIDTH = 14.0;
TP_PORT_HEIGHT = 7.5;
TP_SWITCH_WIDTH = 16.0;         // Power switch access cutout
TP_SWITCH_HEIGHT = 10.0;
LIP_RECESS = 1.0;               // Tray rim height offset below trackpad surface (glass is 1mm proud)

/* [Elevated Shelf Geometry] */
SHELF_ELEVATION_Z = 46.0;       // Vertical rise of trackpad shelf above runner floor
SHELF_SETBACK_Y = 16.0;         // Setback behind keyboard rear edge
SHELF_TILT_ANGLE = 6.0;         // Ergonomic forward tilt angle (degrees)
SHELF_FLOOR_THICKNESS = 2.5;

/* [Lap Runner & Strut Geometry] */
RUNNER_WIDTH = 26.0;
RUNNER_THICKNESS = 5.0;
STRUT_SPACING = 114.0;          // Spacing between left and right lap runners
CORNER_R = 2.0;                 // Consistent global fillet/rounding radius

/* [Keyboard Retention Hardware Settings] */
FRONT_LIP_WALL = 5.5;           // Front wall thickness of continuous retaining chin
FRONT_CATCH_DEPTH = 3.5;        // Overhang catch tab depth across full front span
FRONT_LIP_GAP = 7.6;            // Snug 7.6mm sloped opening for 6.5mm keyboard front
FRONT_LIP_HEIGHT = RUNNER_THICKNESS + FRONT_LIP_GAP + 2.2; // Total height (~14.8mm)

REAR_JAW_WALL = 14.0;           // Heavy-duty structural rear fulcrum wall for maximum moment stiffness
REAR_JAW_TOP_THICKNESS = 5.5;   // Thick top clamping beam resisting cantilever lifting loads
REAR_JAW_OVERHANG = 13.5;       // Deep forward overhang locking over >50% of the rear battery bar
REAR_JAW_HEIGHT = RUNNER_THICKNESS + KB_BATTERY_BAR_HEIGHT + REAR_JAW_TOP_THICKNESS; // ~30.8mm total height

/* [Riser & Crossbrace Settings] */
RISER_THICKNESS = 10.0;         // Substantially thickened riser arms for zero flex
CROSSBRACE_WIDTH = 20.0;

/* [Tolerances & Quality] */
$fn = 72;

// ==========================================
// Top-Level Scene Selection
// ==========================================
if (MODE == "assembled") {
    monolithic_assembly();
    if (SHOW_DEVICES && $preview) installed_devices();
    if (SHOW_BED_BOUNDS) prusa_mini_bounds();
} else if (MODE == "single_piece_diagonal") {
    translate([0, 0, BED_Z / 2])
        zrot(45)
            xrot(-35) {
                monolithic_assembly();
                if (SHOW_DEVICES && $preview) installed_devices();
            }
    if (SHOW_BED_BOUNDS) prusa_mini_bounds();
} else if (MODE == "cradle_only") {
    keyboard_lap_cradle();
    if (SHOW_DEVICES && $preview) installed_keyboard();
    if (SHOW_BED_BOUNDS) prusa_mini_bounds();
} else if (MODE == "shelf_only") {
    trackpad_shelf_assembly();
    if (SHOW_DEVICES && $preview) installed_trackpad();
    if (SHOW_BED_BOUNDS) prusa_mini_bounds();
}

module prusa_mini_bounds() {
    %translate([0, 0, BED_Z / 2])
        cube([BED_X, BED_Y, BED_Z], center = true);
}

// ==========================================
// Installed Hardware Models (Fit Verification)
// ==========================================
module installed_devices() {
    installed_keyboard();
    installed_trackpad();
}

module installed_keyboard() {
    translate([0, 0, RUNNER_THICKNESS])
        mx_keys_mini(anchor = BOT);
}

module installed_trackpad() {
    rear_y = KB_DEPTH / 2 + KB_FIT_TOLERANCE;
    translate([0, rear_y + SHELF_SETBACK_Y, SHELF_ELEVATION_Z])
        xrot(SHELF_TILT_ANGLE)
            translate([0, 0, SHELF_FLOOR_THICKNESS])
                magic_trackpad(anchor = BOT);
}

// ==========================================
// Monolithic Unified Assembly (Single Piece)
// ==========================================
module monolithic_assembly() {
    color([0.88, 0.72, 0.15]) { // Gold/amber 3D print filament
        union() {
            keyboard_lap_cradle();
            trackpad_shelf_assembly();
        }
    }
}

// ==========================================
// Module: Seamless Keyboard Lap Base Skeleton
// ==========================================
module keyboard_lap_cradle() {
    front_y = -KB_DEPTH / 2;
    rear_y = KB_DEPTH / 2 + KB_FIT_TOLERANCE;

    union() {
        // Continuous lap runners extending full length
        xcopies(spacing = STRUT_SPACING, n = 2) {
            single_monolithic_runner(front_y = front_y, rear_y = rear_y);
        }

        // Full-width monolithic front retaining chin (140mm continuous beam)
        continuous_front_retaining_chin(front_y = front_y);

        // Front crossbrace linking the runners (spans cleanly between runner centers)
        translate([0, front_y + CROSSBRACE_WIDTH / 2 + 2, 0])
            cuboid([STRUT_SPACING, CROSSBRACE_WIDTH, RUNNER_THICKNESS], rounding = CORNER_R, edges = [FWD+BOT, BACK+BOT], anchor = BOT);

        // Middle X-crossbrace across lap span
        x_lap_crossbrace(
            span_x = STRUT_SPACING,
            y_front = front_y + CROSSBRACE_WIDTH / 2 + 2,
            y_rear = rear_y - KB_BATTERY_BAR_DEPTH / 2,
            bar_w = CROSSBRACE_WIDTH * 0.75,
            thickness = RUNNER_THICKNESS,
            r = CORNER_R
        );

        // Rear crossbrace anchoring the battery clamp and riser base
        translate([0, rear_y - KB_BATTERY_BAR_DEPTH / 2, 0])
            cuboid([STRUT_SPACING, KB_BATTERY_BAR_DEPTH, RUNNER_THICKNESS], rounding = CORNER_R, edges = [FWD+BOT, BACK+BOT], anchor = BOT);

        // Integrated Rear Battery Clamp Jaws (2x)
        xcopies(spacing = STRUT_SPACING, n = 2) {
            translate([0, rear_y, 0])
                rear_battery_jaw();
        }
    }
}

module continuous_front_retaining_chin(front_y = -KB_DEPTH / 2) {
    total_w = STRUT_SPACING + RUNNER_WIDTH; // 140.0mm full-width continuous beam
    lip_depth = FRONT_LIP_WALL + FRONT_CATCH_DEPTH;
    lip_rise = FRONT_LIP_HEIGHT - RUNNER_THICKNESS;

    diff() {
        // 1. Full-width upright retaining hook bar (continuous 140mm wide)
        translate([0, front_y - FRONT_LIP_WALL, RUNNER_THICKNESS])
            cuboid(
                [total_w, lip_depth, lip_rise],
                rounding = CORNER_R,
                edges = [FRONT+TOP, BACK+TOP, FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT],
                anchor = BOT+FRONT
            );

        // 2. Full-width subtractive pocket angled at KB_TILT_ANGLE (5.5 deg)
        tag("remove")
            translate([0, front_y - 0.8, RUNNER_THICKNESS])
                xrot(KB_TILT_ANGLE)
                    cuboid([total_w + 4, FRONT_CATCH_DEPTH + 8, FRONT_LIP_GAP + 0.4], rounding = 1.0, edges = "Y", anchor = BOT+FRONT);
    }
}

module single_monolithic_runner(front_y = -KB_DEPTH / 2, rear_y = KB_DEPTH / 2 + KB_FIT_TOLERANCE) {
    total_len = (rear_y + REAR_JAW_WALL) - (front_y - FRONT_LIP_WALL);

    // Full-length bottom runner rail with continuous bottom fillets AND front vertical corner fillets
    translate([0, front_y - FRONT_LIP_WALL, 0])
        cuboid(
            [RUNNER_WIDTH, total_len, RUNNER_THICKNESS],
            rounding = CORNER_R,
            edges = [LEFT+BOT, RIGHT+BOT, FRONT+BOT, BACK+BOT, FRONT+LEFT, FRONT+RIGHT],
            anchor = BOT+FRONT
        );
}

module rear_battery_jaw() {
    jaw_total_depth = REAR_JAW_WALL + REAR_JAW_OVERHANG;
    jaw_rise = REAR_JAW_HEIGHT - RUNNER_THICKNESS;

    diff() {
        // Upright clamp block rising from base runner with heavy structural rear support
        translate([0, (REAR_JAW_WALL - REAR_JAW_OVERHANG) / 2, RUNNER_THICKNESS + jaw_rise / 2])
            cuboid([RUNNER_WIDTH, jaw_total_depth, jaw_rise], rounding = CORNER_R, except = [BOT]);

        // Deep Moment-Resisting Rear Pocket: firmly encases top, back, and underside of battery bar
        tag("remove")
            translate([0, -REAR_JAW_OVERHANG / 2 - 0.1, RUNNER_THICKNESS])
                xrot(KB_TILT_ANGLE)
                    translate([0, 0, KB_BATTERY_BAR_HEIGHT / 2])
                        cuboid([RUNNER_WIDTH + 2, REAR_JAW_OVERHANG + 1.5, KB_BATTERY_BAR_HEIGHT], rounding = 1.0, edges = "Y", anchor = CENTER);

        // Entry lead-in chamfer on the lower lip of the top clamping beam for effortless slide-in
        tag("remove")
            translate([0, -REAR_JAW_OVERHANG, REAR_JAW_HEIGHT - REAR_JAW_TOP_THICKNESS])
                xrot(-30)
                    cuboid([RUNNER_WIDTH + 4, 3.0, 3.0], anchor = BOT+BACK);
    }
}

module x_lap_crossbrace(span_x, y_front, y_rear, bar_w, thickness, r) {
    y_center = (y_front + y_rear) / 2;
    dy = y_rear - y_front;
    dx = span_x;
    diag_len = hypot(dx, dy) + RUNNER_WIDTH / 2;
    angle = atan2(dy, dx);

    translate([0, y_center, 0]) {
        intersection() {
            // Keep X-arms inside runner centers so outer rail sides remain completely smooth and unblemished
            cuboid([span_x, dy + CROSSBRACE_WIDTH, thickness * 2], anchor = BOT);

            union() {
                zrot(angle)
                    cuboid([diag_len, bar_w, thickness], rounding = r, edges = [FWD+BOT, BACK+BOT], anchor = BOT);
                zrot(-angle)
                    cuboid([diag_len, bar_w, thickness], rounding = r, edges = [FWD+BOT, BACK+BOT], anchor = BOT);
            }
        }
    }
}

// ==========================================
// Module: Elevated Trackpad Shelf & Integrated Riser
// ==========================================
module trackpad_shelf_assembly() {
    rear_y = KB_DEPTH / 2 + KB_FIT_TOLERANCE;

    union() {
        // Integrated Monolithic Cantilever Riser Struts
        riser_struts(rear_y = rear_y);

        // Elevated Trackpad Tray positioned above & behind function keys
        translate([0, rear_y + SHELF_SETBACK_Y, SHELF_ELEVATION_Z])
            xrot(SHELF_TILT_ANGLE)
                trackpad_tray();
    }
}

module riser_struts(rear_y = KB_DEPTH / 2 + KB_FIT_TOLERANCE) {
    union() {
        // Twin heavy-duty curved cantilever arms fused seamlessly into the rear jaw clamp
        xcopies(spacing = STRUT_SPACING, n = 2) {
            single_integrated_riser(rear_y = rear_y);
        }

        // Solid, continuous structural center crossbrace (no cutouts, maximizing torsional rigidity)
        backplate_center_z = (REAR_JAW_HEIGHT + SHELF_ELEVATION_Z - 2) / 2;
        backplate_center_y = rear_y + (REAR_JAW_WALL + SHELF_SETBACK_Y) / 2;
        backplate_h = (SHELF_ELEVATION_Z - REAR_JAW_HEIGHT) / cos(15);

        translate([0, backplate_center_y, backplate_center_z])
            xrot(15)
                cuboid([STRUT_SPACING + RUNNER_WIDTH, RISER_THICKNESS, backplate_h + 4], rounding = CORNER_R, anchor = CENTER);
    }
}

module single_integrated_riser(rear_y = KB_DEPTH / 2 + KB_FIT_TOLERANCE) {
    // Seamless thick structural hull connecting the top and rear of the battery jaw to the shelf underside
    hull() {
        // Base connection: fully envelopes the thick top and back wall of the battery jaw
        translate([0, rear_y + (REAR_JAW_WALL - REAR_JAW_OVERHANG) / 2, REAR_JAW_HEIGHT - REAR_JAW_TOP_THICKNESS / 2])
            cuboid([RUNNER_WIDTH, REAR_JAW_WALL + REAR_JAW_OVERHANG, REAR_JAW_TOP_THICKNESS], rounding = CORNER_R, anchor = CENTER);

        // Upper connection: terminates cleanly against the underside of the trackpad tray (anchor = TOP)
        translate([0, rear_y + SHELF_SETBACK_Y, SHELF_ELEVATION_Z])
            xrot(SHELF_TILT_ANGLE)
                cuboid([RUNNER_WIDTH, 28, RISER_THICKNESS], rounding = CORNER_R, anchor = TOP);
    }
}

module trackpad_tray() {
    outer_w = TP_WIDTH + TP_WALL_THICKNESS * 2;
    outer_d = TP_DEPTH + TP_WALL_THICKNESS * 2;

    // Sloped tray rim heights (1.0mm lower than Magic Trackpad wedge surface at all points)
    tray_front_h = SHELF_FLOOR_THICKNESS + TP_FRONT_H - LIP_RECESS; // 6.5mm total (4.0mm wall)
    tray_rear_h = SHELF_FLOOR_THICKNESS + TP_REAR_H - LIP_RECESS;   // 13.0mm total (10.5mm wall)
    max_h = tray_rear_h + 15;
    mid_h = (tray_front_h + tray_rear_h) / 2;
    wedge_angle = atan((tray_rear_h - tray_front_h) / outer_d);

    // Power toggle position on Apple Magic Trackpad 2/3 (22mm from right edge -> X = +58.25mm)
    switch_center_x = TP_WIDTH / 2 - 22.0;
    switch_width = 18.0;

    diff() {
        // 1. Main outer tray solid with rounded vertical corners
        cuboid([outer_w, outer_d, max_h], rounding = TP_CORNER_R + TP_WALL_THICKNESS, edges = "Z", anchor = BOT);

        // 2. Angled planar slice: slopes the entire top rim from front (4mm wall) to rear (10.5mm wall)
        tag("remove")
            translate([0, 0, mid_h])
                xrot(wedge_angle)
                    cuboid([outer_w + 20, outer_d * 2, max_h + 10], anchor = BOT);

        // 3. Trackpad Recessed Cavity: Flat bottom with crisp 90° edges and rounded vertical corners (edges = "Z")
        tag("remove")
            translate([0, 0, SHELF_FLOOR_THICKNESS])
                cuboid([TP_WIDTH, TP_DEPTH, max_h + 2], rounding = TP_CORNER_R, edges = "Z", anchor = BOT);

        // 4. Rear Charging Port Cutout (Lightning / USB-C centered)
        tag("remove")
            translate([0, outer_d / 2, SHELF_FLOOR_THICKNESS + TP_PORT_HEIGHT / 2 + 1])
                cuboid([TP_PORT_WIDTH, TP_WALL_THICKNESS * 2 + 2, TP_PORT_HEIGHT], rounding = CORNER_R, edges = "Y", anchor = CENTER);

        // 5. Ergonomic Power Switch Cutout with Rounded-Over Top Edges & Filleted Base
        tag("remove")
            translate([switch_center_x, outer_d / 2, 0])
                power_switch_smooth_notch(
                    width = switch_width,
                    floor_z = SHELF_FLOOR_THICKNESS,
                    rim_z = tray_rear_h,
                    wall_thickness = TP_WALL_THICKNESS
                );

        // 6. Rear-facing Semicircular Finger Push Notch (accessed from open rear area)
        tag("remove")
            translate([0, 10, -0.5])
                intersection() {
                    cyl(d = 30, h = SHELF_FLOOR_THICKNESS + 2, anchor = BOT);
                    translate([0, 15, 0])
                        cuboid([32, 30, SHELF_FLOOR_THICKNESS + 4], anchor = BOT);
                }
    }
}

module power_switch_smooth_notch(width, floor_z, rim_z, wall_thickness) {
    r_bot = 2.0; // Fillet radius at the base of the trough
    r_top = 2.5; // Convex round-over radius at the top rim
    cut_h = (rim_z - floor_z) + 4;
    cut_d = wall_thickness * 2 + 6;

    union() {
        // 1. Main slot with rounded bottom corners (creates concave fillets at the trough base)
        translate([0, 0, floor_z])
            cuboid([width, cut_d, cut_h], rounding = r_bot, edges = [BOT+LEFT, BOT+RIGHT], anchor = BOT);

        // 2. Left top rim convex waterfall round-over
        translate([-width / 2, 0, rim_z])
            xrot(90)
                linear_extrude(cut_d, center = true)
                    difference() {
                        translate([-r_top, -r_top]) square([r_top, r_top]);
                        translate([-r_top, -r_top]) circle(r = r_top);
                    }

        // 3. Right top rim convex waterfall round-over
        translate([width / 2, 0, rim_z])
            xrot(90)
                linear_extrude(cut_d, center = true)
                    difference() {
                        translate([0, -r_top]) square([r_top, r_top]);
                        translate([r_top, -r_top]) circle(r = r_top);
                    }
    }
}
