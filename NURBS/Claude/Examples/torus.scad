include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//
R = 30; r = 10;    // major / minor torus radii
N = 6;             // 6 samples each way  (N > p+1 = 4 for cubic)
data = [for (i = [0:1:N-1])
    let(phi = i * 360/N)
    [for (j = [0:1:N-1])
        let(theta = j * 360/N)
        [(R + r*cos(theta))*cos(phi),
         (R + r*cos(theta))*sin(phi),
         r*sin(theta)]]
];
vnf = nurbs_interp_vnf(data, 3, splinesteps=12,
          type=["closed","closed"]);
vnf_polyhedron(vnf);