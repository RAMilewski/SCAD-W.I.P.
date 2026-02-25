// ---- Example 13: Surface closed in one direction (tube) ----
//   Closed around the v-direction (the rings), clamped in u (along the
//   axis).  Uses 5 rings rather than 4: a cubic closed direction needs
//   at least p+2 = 5 data rows/columns to have interior knot freedom.
//   With only p+1 = 4, the system is solvable but the closed direction
//   has no interior flexibility and produces results nearly identical to
//   the clamped case.
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
r = 20;
data = [for (u = [0:15:60])      // 5 rings: u = 0,15,30,45,60
    [for (i = [0:5])
        let(a = i * 360/6)
        [r*cos(a), r*sin(a), u]]
];
vnf = nurbs_interp_vnf(data, 3, splinesteps=8,
          type=["closed","closed"]);
vnf_polyhedron(vnf);