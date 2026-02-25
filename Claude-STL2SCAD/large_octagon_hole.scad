//////////////////////////////////////////////////////////////////////
// Large Octagon Hole — OpenSCAD/BOSL2 Reconstruction  v2
// Source STL: "Large Octagon Hole.stl"
// Target volume: 656.86 mm³
// Tolerance goal: ≤ 0.1 mm dimensional accuracy
//
// v1: simple outer+bore+chamfer → 711.73 mm³ (too high by 54.87 mm³)
// v2: adds irregular hub bore + 4 diagonal outer notch slots
//////////////////////////////////////////////////////////////////////

include <BOSL2/std.scad>

// ============================================================
// PARAMETERS  (surfaced here for Customizer)
// ============================================================

// Outer octagon flat-to-flat / 2  (apothem)
OUTER_APOTHEM          = 12.5;    // mm

// Total part height
TOTAL_HEIGHT           = 6.2;     // mm

// Inner bore axial face apothem  (±X, ±Y faces; all zones)
BORE_APOTHEM           = 10.7;    // mm

// Hub bore diagonal face apothem (slightly wider; hub zone only)
// Gives hub bore cross-section area ≈ 387 mm²
HUB_BORE_DIAG_APOTHEM = 10.92;   // mm

// Bore opening apothem at top and bottom faces
OPENING_APOTHEM        = 11.7;    // mm

// Chamfer depth at each end  (Z 0→2 bottom, Z 4.2→6.2 top)
CHAMFER_DEPTH          = 2.0;     // mm

// Hub (straight bore) height = TOTAL_HEIGHT − 2×CHAMFER_DEPTH
HUB_HEIGHT             = TOTAL_HEIGHT - 2 * CHAMFER_DEPTH;  // 2.2 mm

// Outer diagonal notch slot — inner-wall apothem (hub zone, 4 slots)
HUB_SLOT_INNER_APOTHEM = 11.9;   // mm   (slot depth = 12.5 − 11.9 = 0.6 mm)

// Outer diagonal notch slot — tangential width
HUB_SLOT_WIDTH         = 7.04;   // mm

// Octagon spin: 22.5° puts flat faces on ±X and ±Y axes
OCT_SPIN               = 22.5;   // degrees

// ============================================================
// HELPERS
// ============================================================

// 2-D regular octagon, apothem a, oriented per OCT_SPIN
module oct2d(a) {
    regular_ngon(n=8, ir=a, spin=OCT_SPIN);
}

// 3-D octagonal prism: height h, apothem a
module oct_prism(h, a) {
    linear_extrude(height=h, center=false) oct2d(a);
}

// Octagonal frustum: height h, bottom apothem a_bot, top apothem a_top
module oct_frustum(h, a_bot, a_top) {
    linear_extrude(height=h, center=false, scale=a_top/a_bot)
        oct2d(a_bot);
}

// 2-D irregular octagon for the hub bore.
//
//   Axial faces  (±X, ±Y):               apothem = BORE_APOTHEM       (10.7 mm)
//   Diagonal faces (45°/135°/225°/315°): apothem = HUB_BORE_DIAG_APOTHEM (10.92 mm)
//
//   Vertex where axial face x = a1 meets diagonal face x+y = a2·√2:
//       v = a2·√2 − a1  ≈ 4.744 mm
//
//   Cross-section area ≈ 387 mm² (measured from source STL at Z=3.0)
module hub_bore_2d() {
    a1 = BORE_APOTHEM;
    a2 = HUB_BORE_DIAG_APOTHEM;
    v  = a2 * sqrt(2) - a1;          // ≈ 4.744 mm
    polygon(points=[
        [ a1,  v], [ v,  a1],
        [-v,  a1], [-a1,  v],
        [-a1, -v], [-v, -a1],
        [ v, -a1], [ a1, -v]
    ]);
}

// 4 rectangular outer notch slots at the diagonal corners of the hub zone.
// Each slot is open through the outer diagonal face of the part.
//   Depth  = OUTER_APOTHEM − HUB_SLOT_INNER_APOTHEM  (0.6 mm radial)
//   Width  = HUB_SLOT_WIDTH  (6.07 mm tangential)
//   Height = HUB_HEIGHT  (2.2 mm, Z local 0..HUB_HEIGHT)
module hub_slots_void() {
    slot_depth = OUTER_APOTHEM - HUB_SLOT_INNER_APOTHEM;        // 0.6 mm
    slot_r     = (HUB_SLOT_INNER_APOTHEM + OUTER_APOTHEM) / 2;  // 12.2 mm
    eps        = 0.02;
    for (angle = [45, 135, 225, 315])
        rotate([0, 0, angle])
        translate([slot_r, 0, HUB_HEIGHT / 2])
            cube([slot_depth + eps, HUB_SLOT_WIDTH, HUB_HEIGHT + eps],
                 center=true);
}

// ============================================================
// MAIN MODULE
// ============================================================

module large_octagon_hole() {
    difference() {

        // ── Outer solid octagonal prism ──────────────────────────────
        oct_prism(h=TOTAL_HEIGHT, a=OUTER_APOTHEM);

        // ── Inner bore void ──────────────────────────────────────────
        union() {

            // Bottom chamfer frustum  (Z = 0 → CHAMFER_DEPTH)
            // Tapers OPENING_APOTHEM → BORE_APOTHEM
            translate([0, 0, -0.01])
                oct_frustum(h     = CHAMFER_DEPTH + 0.02,
                            a_bot = OPENING_APOTHEM,
                            a_top = BORE_APOTHEM);

            // Hub zone (Z = CHAMFER_DEPTH → CHAMFER_DEPTH + HUB_HEIGHT)
            //   • Irregular octagonal bore (axial a=10.7, diagonal a=10.92)
            //   • 4 diagonal outer notch slots open to exterior
            translate([0, 0, CHAMFER_DEPTH]) {
                linear_extrude(height=HUB_HEIGHT, center=false)
                    hub_bore_2d();
                hub_slots_void();
            }

            // Top chamfer frustum  (Z = CHAMFER_DEPTH+HUB_HEIGHT → TOTAL_HEIGHT)
            // Tapers BORE_APOTHEM → OPENING_APOTHEM
            translate([0, 0, CHAMFER_DEPTH + HUB_HEIGHT - 0.01])
                oct_frustum(h     = CHAMFER_DEPTH + 0.02,
                            a_bot = BORE_APOTHEM,
                            a_top = OPENING_APOTHEM);
        }
    }
}

// ============================================================
// RENDER
// ============================================================

large_octagon_hole();
