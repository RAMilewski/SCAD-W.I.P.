// Include BOSL2:
include <BOSL2/std.scad>;

// Rectangular cover plate with sidewalls along X (the long dimension).
// Inside gap between walls = fit_width + clearance (40 mm by default).
module cover_plate(
    L = 90,              // overall length (X). Must be > W.
    fit_width = 40,      // exact width of the object to fit between walls
    T = 4,               // plate thickness (Z)
    wall_h = 3,          // sidewall height (Z above the plate)
    wall_t = 2,          // sidewall thickness (Y)
    clearance = 0.0,     // add e.g. 0.2 for an easy slip-fit
    r_plate = 1.0,       // rounding radius for the plate corners (plan view)
    r_wall  = 0.8        // rounding radius for wall corner edges (plan view)
){
    // Derived overall width:
    W_inside = fit_width + clearance;
    W = W_inside + 2*wall_t;
    assert(L > W, "Require L > W.");

    // Clamp radii so they can't exceed half of the relevant thicknesses
    r_plate_eff = min(r_plate, min(L,W)/2);
    r_wall_eff  = min(r_wall,  min(wall_t, L)/2);

    // Build
    union() {
        // Base plate, rounded in plan (round vertical/Z edges)
        // Rounding "Z" rounds the 4 vertical edges -> rounded XY corners.
        cuboid([L, W, T], rounding = r_plate_eff, edges = "Z", anchor=CENTER);

        // Sidewalls: two long walls along X, sitting on the plate.
        // We round their vertical edges too (nice softened wall corners).
        // The inside gap (between the two inner faces) stays W_inside.
        y_off = (W_inside/2) + (wall_t/2);
        up(T/2 + wall_h/2) {
            // left wall (negative Y)
            translate([0, -y_off, 0])
                cuboid([L, wall_t, wall_h], rounding = r_wall_eff, edges = "Z");

            // right wall (positive Y)
            translate([0,  y_off, 0])
                cuboid([L, wall_t, wall_h], rounding = r_wall_eff, edges = "Z");
        }
    }

    // Helpful readout
    echo("Overall size: ", [L, W, T]);
    echo("Inside gap between walls: ", W_inside);
}

// ---- Example call ----
cover_plate(
    L = 95,          // choose any length > W; W is computed
    fit_width = 40,  // fits a 40 mm wide object
    T = 4,           // nominal thickness
    wall_h = 3,      // requested wall height
    wall_t = 2,      // wall thickness
    clearance = 0.0, // set to 0.2 if you want slip-fit
    r_plate = 1.2,   // plate corner rounding
    r_wall  = 0.8    // wall corner rounding
);
