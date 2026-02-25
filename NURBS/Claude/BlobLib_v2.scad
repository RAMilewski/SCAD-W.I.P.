include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>

// =====================================================================
// NURBS BLOB GALLERY
//
// All shapes use type=["clamped","closed"]:
//   u (rows)    : clamped — runs pole-to-pole along the long axis
//   v (columns) : closed  — wraps 360° around the circumference
//
// Uncomment one block at a time to render it.
// =====================================================================

$vpt = [0,0,0];

// ---- 1. POTATO -------------------------------------------------------
//   ~120 long, ~82-85 wide.  Hand-crafted irregularity: elliptical
//   cross-sections (ax ≠ ay), a gently curved spine (per-ring cx/cy
//   offsets), a side bump near z=-30, and a slight dent near z=22.
//   One end is more pointed, the other blunter.
//
//   Grid: 9 rings (clamped) × 8 angles (closed, Δθ=45°)


potato = [
    // z=-52  pole — pointed end
    [[0,0,-52],[0,0,-52],[0,0,-52],[0,0,-52],
     [0,0,-52],[0,0,-52],[0,0,-52],[0,0,-52]],
    // z=-47
    [[24, -3,-47], [18, 10,-47], [ 2, 16,-47], [-14, 10,-47],
     [-20, -3,-47], [-14,-16,-47], [ 2,-22,-47], [18,-16,-47]],
    // z=-30  side-bump at θ≈0°  (cx=3, ax=37 → base 40, pushed to 43)
    [[43,  2,-30], [30, 27,-30], [ 3, 36,-30], [-23, 26,-30],
     [-34,  2,-30], [-23,-22,-30], [ 3,-32,-30], [29,-22,-30]],
    // z=-12  widest region
    [[39,  4,-12], [29, 32,-12], [-2, 41,-12], [-31, 30,-12],
     [-43,  4,-12], [-31,-22,-12], [-2,-33,-12], [27,-22,-12]],
    // z= 6
    [[41,  3,  6], [29, 28,  6], [ 1, 39,  6], [-27, 28,  6],
     [-39,  3,  6], [-27,-22,  6], [ 1,-33,  6], [29,-22,  6]],
    // z=22  slight dent at θ=180° (-31 → -28)
    [[35, -2, 22], [25, 19, 22], [ 2, 27, 22], [-21, 19, 22],
     [-28, -2, 22], [-21,-23, 22], [ 2,-31, 22], [25,-23, 22]],
    // z=38
    [[21,  1, 38], [15, 14, 38], [-1, 20, 38], [-17, 14, 38],
     [-23,  1, 38], [-17,-12, 38], [-1,-18, 38], [15,-12, 38]],
    // z=51
    [[12,  2, 51], [ 8,  9, 51], [ 0, 12, 51], [-8,  9, 51],
     [-12,  2, 51], [-8, -5, 51], [ 0, -8, 51], [ 8, -5, 51]],
    // z=60  pole — blunt end
    [[0,0,55],[0,0,55],[0,0,55],[0,0,55],
     [0,0,55],[0,0,55],[0,0,55],[0,0,55]],
];

vnf_polyhedron(nurbs_interp_vnf(potato, 3, splinesteps=12,
    type=["clamped","closed"]));
/* */

// ---- 2. EGG ----------------------------------------------------------
//   ~103 long, ~82 wide.  Smooth parametric ovoid.
//   Blunt at +z, pointed at -z.
//   Profile: r = 40·sin(φ)·(1 − 0.25·cos(φ)),  z = −52·cos(φ)
//   The asymmetry term shifts the belly toward the blunt end.
//
//   Grid: 9 rings × 8 angles
/*

egg = [for (i = [0:8])
    let(phi = i * 180/8,
        r   = 40 * sin(phi) * (1 - 0.25*cos(phi)),
        z   = -52 * cos(phi))
    [for (j = [0:7])
        let(theta = j * 45)
        [r*cos(theta), r*sin(theta), z]
    ]
];

vnf_polyhedron(nurbs_interp_vnf(egg, 3, splinesteps=12,
    type=["clamped","closed"]));
/* */


// ---- 3. RIVER PEBBLE -------------------------------------------------
//   ~50 tall, ~80 wide.  Oblate blob with an organic bumpy surface.
//   Two overlapping sinusoids (different frequencies in θ and φ)
//   create the surface texture; the NURBS smooths them into gentle
//   undulations.
//
//   Grid: 9 rings × 8 angles

/*
pebble = [for (i = [0:8])
    let(phi = i * 180/8,
        z   = -25 * cos(phi))
    [for (j = [0:7])
        let(theta  = j * 45,
            r_base = 40 * sin(phi),
            bump   = sin(phi) * (4*sin(theta*2 + phi*1.4) + 2*cos(theta*3 + phi*0.7)),
            r      = r_base + bump)
        [r*cos(theta), r*sin(theta), z]
    ]
];

vnf_polyhedron(nurbs_interp_vnf(pebble, 3, splinesteps=12,
    type=["clamped","closed"]));
/* */


// ---- 4. GOURD / SQUASH -----------------------------------------------
//   ~116 long.  Fat body (≈80 dia) joined through a narrow waist (≈28
//   dia) to a smaller swelling neck (≈48 dia), then tapering to a tip.
//   The per-ring (cx,cy) offsets give each section a gentle lean.
//
//   Grid: 11 rings (clamped) × 8 angles (closed)

/*
gourd = [
    for (row = [
        //   z    r   cx  cy
        [ -50.5,  0,  0,  0],   // pole — bottom tip
        [ -46, 28,  1, -1],
        [ -28, 40,  2,  1],   // body peak  (dia ≈ 80)
        [ -12, 38, -1,  2],
        [   2, 28,  1,  1],
        [  12, 14,  0,  0],   // waist      (dia ≈ 28)
        [  22, 24, -1, -1],   // neck swell
        [  35, 20,  1,  0],
        [  45, 13,  0,  1],
        [  53,  6,  0,  0],
        [  55,  0,  0,  0],   // pole — stem tip
    ])
    let(z=row[0], r=row[1], cx=row[2], cy=row[3])
    [for (j = [0:7])
        let(theta = j * 45)
        [cx + r*cos(theta), cy + r*sin(theta), z]
    ]
];

vnf_polyhedron(nurbs_interp_vnf(gourd, 3, splinesteps=12,
    type=["clamped","closed"]));
/* */
