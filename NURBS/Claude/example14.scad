// ---- Example 14: Surface closed in both directions (torus) ----
//   For ["closed","closed"] to produce a shape visibly different from
//   ["clamped","closed"], two conditions must both be met:
//
//   1. ENOUGH POINTS: each direction needs at least p+2 points so the
//      periodic system has at least one interior knot with genuine
//      freedom.  With exactly p+1 points the system is solvable but
//      there is no interior flexibility, and the result looks nearly
//      identical to the clamped case.
//
//   2. BALANCED PARAMETERIZATION: the data must form an actual closed
//      loop in each direction.  For chord-length parameterization the
//      "closing" segment (last point back to first) is included in the
//      parameter budget.  If that segment is much longer than the inter-
//      point distances the closed direction folds back on itself rather
//      than forming a smooth loop.  Use evenly-spaced data, or data
//      whose first and last points coincide (so the closing chord is
//      zero and parameter spacing is uniform).
//
//   The canonical example is a torus: both directions sample a full
//   360° circle with even angular spacing, so the closing segment
//   equals the inter-point spacing and parameterization is uniform.
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
R = 30; r = 10;    // major / minor torus radii
N = 6;             // 6 samples each way  (N > p+1 = 4 for cubic)
data = [for (i = [0:N-1])
    let(phi = i * 360/N)
    [for (j = [0:N-1])
        let(theta = j * 360/N)
        [(R + r*cos(theta))*cos(phi),
         (R + r*cos(theta))*sin(phi),
         r*sin(theta)]]
];
vnf = nurbs_interp_vnf(data, 3, splinesteps=12,
          type=["closed","closed"]);
vnf_polyhedron(vnf);
//