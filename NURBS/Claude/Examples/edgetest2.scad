include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>

// Surface data: flat boundary edges (z=0), bumpy interior.
// All four boundary edges are collinear (z=0), so all four
// derivative constraints can be specified simultaneously.

data = [
     [[-50, 50,  0], [-16, 50,  0], [ 16, 50,  0], [30, 50,  0], [50, 50,  0]],
     [[-50, 16,  0], [-16, 16, 40], [ 16, 16, 30], [30, 16, 20], [50, 16,  0]],
     [[-50,-16,  0], [-16,-16, 35], [ 16,-16, 40], [30,-16, 15], [50,-16,  0]],
     [[-50,-50,  0], [-16,-50,  0], [ 16,-50,  0], [30,-50,  0], [50,-50,  0]],
];

// ── Ghost-data set for Test 5 ──────────────────────────────────────────────
// Derivative constraints on flat (z=0) boundary rows/cols request a z-slope
// that is physically impossible: if S(u,0)_z = 0 for all u, then
// ∂S/∂u(u,0)_z = 0 identically, regardless of first_row_deriv.  The projection
// fix correctly zeros the impossible component — but that also removes G1.
//
// Solution: extend the data onto the prismoid faces with ghost rows and
// columns.  Prismoid taper = (120-100)/2 / 10 = 1:1 (45°).
// At offset d=5 outside the top edge, z = -d = -5 on the prismoid face.
// No derivative constraints needed; slope is naturally encoded in the data.

d = 5;   // ghost offset (mm) — prismoid taper is 1:1 so z_ghost = -d

data5 = [
    // ghost front row  (y= 55, all z=-d): lies on prismoid front face
    [[-55, 55,-d], [-50, 55,-d], [-16, 55,-d], [ 16, 55,-d], [30, 55,-d], [50, 55,-d], [55, 55,-d]],
    // front boundary   (y= 50, z= 0)
    [[-55, 50,-d], [-50, 50, 0], [-16, 50, 0], [ 16, 50, 0], [30, 50, 0], [50, 50, 0], [55, 50,-d]],
    // interior row 1   (y= 16)
    [[-55, 16,-d], [-50, 16, 0], [-16, 16,40], [ 16, 16,30], [30, 16,20], [50, 16, 0], [55, 16,-d]],
    // interior row 2   (y=-16)
    [[-55,-16,-d], [-50,-16, 0], [-16,-16,35], [ 16,-16,40], [30,-16,15], [50,-16, 0], [55,-16,-d]],
    // back boundary    (y=-50, z= 0)
    [[-55,-50,-d], [-50,-50, 0], [-16,-50, 0], [ 16,-50, 0], [30,-50, 0], [50,-50, 0], [55,-50,-d]],
    // ghost back row   (y=-55, all z=-d): lies on prismoid back face
    [[-55,-55,-d], [-50,-55,-d], [-16,-55,-d], [ 16,-55,-d], [30,-55,-d], [50,-55,-d], [55,-55,-d]],
];

// ── Test 1: no derivative constraints (baseline) ──────────────────────────
fwd(130){
prismoid(size2=50*2,xang=45,yang=45, h=10,anchor=TOP);
debug_nurbs_interp_surface(data, 3, splinesteps=16);
}
// ── Test 2: u-only constraints ────────────────────────────────────────────
// Surface lifts off front and back edges at 45°.
prismoid(size2=50*2,xang=45,yang=45, h=10,anchor=TOP);
debug_nurbs_interp_surface(data, 3, splinesteps=16,
    first_row_deriv=[0,-1,1],
    last_row_deriv=[0,-1,-1]
);

// ── Test 3: v-only constraints ────────────────────────────────────────────
// Surface lifts off left and right edges at 45°.
back(130){
prismoid(size2=50*2,xang=45,yang=45, h=10,anchor=TOP);
debug_nurbs_interp_surface(data, 3, splinesteps=16,
    first_col_deriv=[1,0,1],
    last_col_deriv=[1,0,-1]
);
}
// ── Test 4: all four constraints ──────────────────────────────────────────
// Projection fix keeps all four edges flat (no oscillation), but the z-slope
// is removed from boundary rows/cols — so the surface is G0 only, not G1.
// The surface sits flush on the prismoid top face but does not angle to match
// the prismoid's 45° side faces.
back(260){
prismoid(size2=50*2,xang=45,yang=45, h=10,anchor=TOP);
debug_nurbs_interp_surface(data, 3, splinesteps=16,
    first_row_deriv=[0,-1,1],
    last_row_deriv=[0,-1,-1],
    first_col_deriv=[1,0,1],
    last_col_deriv=[1,0,-1]
);
}

// ── Test 5: ghost rows + ghost columns, no derivative constraints ──────────
// All four edges mate smoothly at 45° with no oscillation.
// Ghost rows (y=±55) and ghost columns (x=±55) lie on the prismoid faces at
// z=-5.  The B-spline interpolates through them, naturally encoding the slope.
// The z<0 portion of the surface is inside the prismoid body (correct).
back(390){
prismoid(size2=50*2,xang=45,yang=45, h=10,anchor=TOP);
debug_nurbs_interp_surface(data5, 3, splinesteps=16);
}
