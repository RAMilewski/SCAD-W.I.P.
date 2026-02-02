//
// Bottle Generator (diagram-sized)
// Requires: BOSL2  (e.g., include <BOSL2/std.scad>)
//
include <BOSL2/std.scad>;
$fn = 180;

// ---------- Customizer ----------
bottle_size = "750ml";                 // [750ml, 700ml, 500ml, 375ml, 200ml]
wall        = 4;                        // [1:0.5:8]
lip_height  = 2;                        // mm (small rim at very top)
base_thick  = 6;                        // mm (solid base thickness)
shoulder_drop_pct = 0.30;               // % of height from top to start shoulder
neck_h_pct       = 0.22;                // % of height that is parallel neck
base_round_pct   = 0.08;                // % of width for bottom round

// ---------- Sizing table (W, H, NeckOD) ----------
function _size_row(tag) =
    tag=="750ml" ? [92, 220, 21.5] :
    tag=="700ml" ? [90, 218, 21.5] :
    tag=="500ml" ? [84, 197, 18.5] :
    tag=="375ml" ? [77, 175, 18.5] :
    tag=="200ml" ? [66, 148, 18.5] : [92,220,21.5];

W = _size_row(bottle_size)[0];
H = _size_row(bottle_size)[1];
NECK_OD = _size_row(bottle_size)[2];

BODY_R   = W/2;
NECK_R   = NECK_OD/2;
INNER_BODY_R = BODY_R - wall;
INNER_NECK_R = max(NECK_R - wall, 1);     // safety
BOTTOM_Z     = 0;
TOP_Z        = H;

shoulder_start_z = TOP_Z - H*shoulder_drop_pct;     // where shoulder begins
neck_start_z     = TOP_Z - H*neck_h_pct;            // straight neck start
base_round_r     = W*base_round_pct;                // bottom rounding radius

// --------- Helpers ---------
// simple cubic bezier sampler
function _bez(p0,p1,p2,p3,t) =
    (1-t)^3*p0 + 3*(1-t)^2*t*p1 + 3*(1-t)*t^2*p2 + t^3*p3;

function _arc_points(r0,z0, r1,z1, n=10) =
    [ for(i=[0:n]) let(t=i/n)
        [ _bez(r0, r0, r1, r1, t), _bez(z0, z0+base_round_r*0.6, z1-base_round_r*0.4, z1, t) ]
    ];

// Make an outer profile (radius, height) polyline for rotate_extrude()
function outer_profile() =
    concat(
        // bottom round-in
        _arc_points(BODY_R-base_round_r, BOTTOM_Z,
                    BODY_R, BOTTOM_Z+base_round_r, 12),

        // vertical body to shoulder start
        [ [BODY_R, shoulder_start_z] ],

        // bezier shoulder into neck radius
        [ for(i=[0:18]) let(t=i/18)
            [ _bez(BODY_R, BODY_R*0.95, BODY_R*0.60, NECK_R, t),
              _bez(shoulder_start_z, (shoulder_start_z+neck_start_z)*0.52,
                   (shoulder_start_z+neck_start_z)*0.85, neck_start_z, t)
            ]
        ],

        // straight neck to top-lip
        [ [NECK_R, TOP_Z-lip_height],
          [NECK_R+0.75, TOP_Z-lip_height/2],     // tiny outward bead
          [NECK_R, TOP_Z] ]
    );

// Inner (void) profile; closed when revolved and subtracted
function inner_profile() =
    concat(
        // vertical inner wall begins above solid base
        [ [INNER_BODY_R, base_thick] ],
        // up to just under shoulder start
        [ [INNER_BODY_R, shoulder_start_z - wall] ],
        // shoulder curve inward to inner neck
        [ for(i=[0:18]) let(t=i/18)
            [ _bez(INNER_BODY_R, INNER_BODY_R*0.95, INNER_BODY_R*0.55, INNER_NECK_R, t),
              _bez(shoulder_start_z - wall,
                   (shoulder_start_z+neck_start_z)*0.50 - wall,
                   (shoulder_start_z+neck_start_z)*0.83 - wall,
                   neck_start_z - wall*0.5, t)
            ]
        ],
        // straight inner neck; stop below very top to keep rim solid
        [ [INNER_NECK_R, TOP_Z - max(lip_height,wall*1.2)] ],
        // close to axis (tiny epsilon) then down through axis to base to form a valid region
        [ [0.01, TOP_Z - max(lip_height,wall*1.2)],
          [0.01, base_thick],
          [INNER_BODY_R, base_thick] ]
    );

// --------- Model ----------
module bottle_solid() {
    difference() {
        // Outer revolved solid
        rotate_extrude(angle=360)
            polygon(points = concat([[0, BOTTOM_Z]], outer_profile(), [[0, BOTTOM_Z]]));
        // Inner void
        rotate_extrude(angle=360)
            polygon(points = inner_profile());
    }
}

// ---------- Build ----------
color("gainsboro") bottle_solid();

// Helpers to show overall guides (toggle on if you like)
*%translate([0,0,0]) cube([W,1,H],center=false);  // width & height gauge
