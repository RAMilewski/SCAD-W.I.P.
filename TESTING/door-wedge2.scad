// ----- Parameters -----
x   = 58;
y   = 50;
z   = 10;
gap = 15;
$fn = 72;

// Rounding radii to match your BOSL2 call
outer_r = 2;   // cuboid([x,y,z], rounding=2)
slot_r  = 4;   // cuboid([...], rounding=4, edges="Z", except=BACK)

// ----- Helpers -----
// 2D rectangle rounded only on the FRONT (positive Y) corners.
// Back (negative Y) corners stay square. Width=W (X), Height=H (Y).
module front_rounded_rect(W, H, r) {
    // Ensure the front capsule core stays non-negative width
    w_core = max(W - 2*r, 0);

    union() {
        // Back+middle: plain rectangle reaching up to (H/2 - r),
        // leaving front r-band for the rounded cap.
        translate([0, -r/2])
            square([W, H - r], center=true);

        // Front r-band with rounded corners via Minkowski with a circle:
        minkowski() {
            translate([0,  H/2 - r/2])
                square([w_core, r], center=true);
            circle(r=r, $fn=$fn);
        }
    }
}

// Fully-rounded cuboid (all edges/corners) with outer size [X,Y,Z] and radius r.
// Implemented by shrinking a core box and Minkowski with a sphere.
module rounded_cuboid_all_edges(X, Y, Z, r) {
    // If r is too big, clamp so dimensions don't go negative.
    rx = min(r, X/2);
    ry = min(r, Y/2);
    rz = min(r, Z/2);
    r  = min(rx, min(ry, rz));

    minkowski() {
        cube([X - 2*r, Y - 2*r, Z - 2*r], center=true);
        sphere(r=r, $fn=$fn);
    }
}

// ----- Model -----
// BOSL2 placement logic reproduced:
// position(BACK+LEFT) => parent anchor at (-x/2, -y/2, 0)
// right(15)           => +X by 15
// then child has anchor=BACK+LEFT => shift by (+gap/2, +30/2) to get its center
slot_center = [
    -x/2 + 15 + gap/2,   // X
    -y/2 + 15,           // Y
    0                    // Z (centered)
];

difference() {
    // Outer rounded block: rounding=2 on all edges/corners
    rounded_cuboid_all_edges(x, y, z, outer_r);

    // Subtractive slot with only FRONT vertical edges rounded
    translate(slot_center)
        linear_extrude(height = z + 0.1, center=true)
            front_rounded_rect(gap, 30, slot_r);
}
