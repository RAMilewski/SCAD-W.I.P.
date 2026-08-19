include <BOSL2/std.scad>

/* [Body] */
// Overall width of the car body.
car_width = 66;
// Roundover radius along both flanks of the body.
side_round = 8;
// Smoothness of the swept side profile.
splinesteps = 32;

$fa = 1;
$fs = 0.5;


// Everything but the wheel arches: tail, roof, nose, and the underside
// running straight from the nose back to the tail.
body_outline = [
    bez_begin([2.5,0], BACK, 15),
    bez_joint([2.5,9], FWD, RIGHT, 10,10),
    bez_joint([2.9,9], LEFT, 0, 9, 1.26),
    bez_joint([5.72,10.97], 250, 70, 1.26, 20),
    bez_tang([80,65], 3, 35, 20),
    bez_joint([128.34,60.61], 160, -20, 10, 1.15),
    bez_joint([130.91,58.48], 121, -59, 1.15, 10),
    bez_joint([138.56,44.5], 120, -60, 10, 1.79),
    bez_joint([142.89,42], 180, 0, 1.79, 55),
    bez_joint([208,11], BACK, -90, 10, 1.11),
    bez_joint([210,9], 180, RIGHT, 1.11, 6),
    bez_joint([211,9], LEFT, FWD, 10,10),
    bez_joint([211,0], BACK, LEFT, 10,10)
];

// The two wheel arches, cut up into that underside.

arches = [
    bez_joint([189,0], RIGHT, 94.85, 10, 9.65),
    bez_tang([170.5,17], LEFT, 9.65),
    bez_joint([152,0], 85.15, LEFT, 9.65, 10),
    bez_joint([52,0], RIGHT, 93.28, 10, 9.55),
    bez_tang([34,17], LEFT, 9.55),
    bez_joint([16,0], 86.72, LEFT, 9.55, 10)
];

closing = [ bez_end([2.5,0], RIGHT,10) ];

// The side view as drawn, arches and all.
bez = flatten(concat(body_outline, arches, closing));

// The same side view with a straight underside.  The body is swept from
// this one, so the flank roundover runs along the bottom of the car
// rather than flaring the arches open; the arches are cut back in after.
body_bez = flatten(concat(body_outline, closing));

//debug_bezier(bez, N = 3);


// The circle a wheel arch is drawn on: ends sitting on the ground line at
// x1 and x2, crown h above it.  Returns [x centre, z centre, radius].
function well_circle(x1, x2, h) =
    let (c = (x2 - x1) / 2, r = (c * c + h * h) / (2 * h))
    [(x1 + x2) / 2, h - r, r];

wells = [well_circle(16, 52, 17), well_circle(152, 189, 17)];

body_profile = bezpath_curve(body_bez, splinesteps = splinesteps);


// The whole car: the straight-bottomed side view swept across the width
// with both flanks rounded over, then the wheel housings cut the full
// width on exactly the circles the arches are drawn on, so they stay
// open and the same shape all the way across for wheels added later.
module car_body() {
    diff() {
        back(car_width / 2)
            xrot(90)
                offset_sweep(
                    body_profile, height = car_width,
                    bottom = os_circle(r = side_round),
                    top    = os_circle(r = side_round),
                    steps = 32, quality = 3
                );
        tag("remove") wheel_housings();
        
    }
}


module wheel_housings() {
    for (w = wells)
        move([w[0], 0, w[1]])
            ycyl(r = w[2], l = car_width + 2);
}


        car_body();