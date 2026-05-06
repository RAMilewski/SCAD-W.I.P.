include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>



//   EGG ----------------------------------------------------------
//   ~103 long, ~82 wide.  Smooth parametric ovoid.
//   Blunt at +z, pointed at -z.
//   Profile: r = 40·sin(φ)·(1 − 0.25·cos(φ)),  z = −52·cos(φ)
//   The asymmetry term shifts the belly toward the blunt end.
//
//   Grid: 9 rings × 8 angles

egg = [for (i = [0:8])
    let(phi = i * 180/8,
        r   = 40 * sin(phi) * (1 - 0.25*cos(phi)),
        z   = -52 * cos(phi))
    [for (j = [0:7])
        let(theta = j * 45)
        [r*cos(theta), r*sin(theta), z]
    ]
];

nurbs_interp_surface(egg, 3, col_wrap = true);
/* */