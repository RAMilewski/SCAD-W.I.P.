include <BOSL2/std.scad>


$fn = 36;
// Parametric cover plate with sidewalls along X (long) dimension.
// The inner gap between walls is `fit_width + clearance` (40mm by default).

module cover_plate(
    L = 80,              // overall length (X), must be > W
    fit_width = 40,      // exact inside gap to fit the object
    T = 4,               // plate thickness (Z)
    wall_h = 3,          // wall height (Z above the plate)
    wall_t = 2,          // wall thickness (Y)
    clearance = 0.0,     // extra width on the inside gap, e.g. 0.2 for slip-fit
    corner_round = 0     // optional outer corner rounding for the plate
) {
    W_inside = fit_width + clearance;    // inner gap between the two walls
    W = W_inside + 2*wall_t;             // overall width (Y)
    assert(L > W, "Require L > W to satisfy 'L x W, L > W'.");

    // Helpful echoes:
    echo("Computed overall width W =", W);
    echo("Inside gap (between walls) =", W_inside);

    // Base plate
    union() {
        // Plate (centered)
        cuboid([L, W, T], rounding=corner_round, except = [TOP])

        // Two sidewalls running along X, placed at
         // Walls sit on top of the plate.
        position(TOP) ycopies(n = 2, spacing = W - wall_t) 
            cuboid([L, wall_t, wall_h], rounding = corner_round, except = BOT,  anchor = BOT);
    }
}

// ---------- Example ----------
cover_plate(
    L = 90,          // pick any length > W
    fit_width = 40,  // fits the 40 mm-wide object exactly
    T = 4,           // nominal thickness
    wall_h = 3,      // requested sidewall height
    wall_t = 2,      // sidewall thickness
    clearance = 0.0, // set to 0.2 if you want an easy slip-fit
    corner_round = 1 // optional: nice rounded plate corners
);
