// BOSL2 bottle made with turtle(), size selector + 4 mm wall
// Requires: include <BOSL2/std.scad>
include <BOSL2/std.scad>;
$fn = 220;

// ---------- Customizer ----------
bottle_size = "750ml";                 // [750ml, 700ml, 500ml, 375ml, 200ml]
wall        = 4;                        // [1:0.5:8]
lip_height  = 2;                        // mm
base_thick  = 6;                        // mm
shoulder_drop_pct = 0.30;               // start of shoulder (from top)
neck_h_pct       = 0.22;                // straight neck fraction of H
base_round_pct   = 0.08;                // bottom outer fillet (as % of W)

// ---------- Size table:  [Width, Height, Neck OD] ----------
function _size_row(tag) =
    tag=="750ml" ? [92, 220, 21.5] :
    tag=="700ml" ? [90, 218, 21.5] :
    tag=="500ml" ? [84, 197, 18.5] :
    tag=="375ml" ? [77, 175, 18.5] :
    tag=="200ml" ? [66, 148, 18.5] : [92,220,21.5];

W = _size_row(bottle_size)[0];
H = _size_row(bottle_size)[1];
NECK_OD = _size_row(bottle_size)[2];

// ------- Derived dimensions -------
BODY_R   = W/2;
NECK_R   = NECK_OD/2;
INNER_BODY_R = BODY_R - wall;
INNER_NECK_R = max(NECK_R - wall, 1);

BOTTOM_Z         = 0;
TOP_Z            = H;
shoulder_start_z = TOP_Z - H*shoulder_drop_pct;
neck_start_z     = TOP_Z - H*neck_h_pct;
base_round_r     = W*base_round_pct;

// straight rises
outer_body_up = max(shoulder_start_z - (BOTTOM_Z + base_round_r), 0.01);
outer_neck_up = max((TOP_Z - lip_height) - neck_start_z, 0.01);

inner_body_up = max((shoulder_start_z - wall) - base_thick, 0.01);
inner_neck_up = max((TOP_Z - max(lip_height, wall*1.2)) - (neck_start_z - wall*0.5), 0.01);

// Shoulder curvature (now bending INWARD with arcleft)
dR = BODY_R - NECK_R;
OR1 = max(dR*0.90, 18);  OA1 = 65;      // outer shoulder arc 1
OR2 = max(dR*0.45,  9);  OA2 = 45;      // outer shoulder arc 2
IR1 = max((INNER_BODY_R-INNER_NECK_R)*0.90, 14); IA1 = 63; // inner shoulder arc 1
IR2 = max((INNER_BODY_R-INNER_NECK_R)*0.45,  7); IA2 = 43; // inner shoulder arc 2

// turtle() returns [x,y,heading] — strip heading for polygon()
function vec2ize(pts) = [ for (p = pts) [p[0], p[1]] ];

// --- OUTER contour (use ARCRIGHT for bottom fillet outward; ARCLEFT for shoulder inward)
function outer_curve_pts() =
    turtle(
        [
            "setdir", 90,                          // up
            "arcright", base_round_r, 90,          // bottom fillet; heading now 0°
            "setdir", 90,                          // ensure vertical before body rise
            "move", outer_body_up,                 // straight cylinder wall

            // Shoulder: bend INWARD toward the neck
            "arcleft", OR1, OA1,
            "arcleft", OR2, OA2,

            // Straight neck up to under the lip bead
            "setdir", 90,
            "move", outer_neck_up,

            // Lip bead
            "right", 90, "move", 0.75, "left", 90,
            "move", lip_height
        ],
        state=[BODY_R - base_round_r, BOTTOM_Z, 0]
    );

// --- INNER contour (mirror inward bends)
function inner_curve_pts() =
    turtle(
        [
            "setdir", 90,
            "move", inner_body_up,
            "arcleft", IR1, IA1,
            "arcleft", IR2, IA2,
            "setdir", 90,
            "move", inner_neck_up
        ],
        state=[INNER_BODY_R, base_thick, 0]
    );

// --- Close profiles for rotate_extrude -------------------------------------
function close_outer_profile() =
    let(pts2 = vec2ize(outer_curve_pts()))
    concat(pts2, [[0, TOP_Z], [0, BOTTOM_Z], [pts2[0][0], pts2[0][1]]]);

function close_inner_profile() =
    let(pts2 = vec2ize(inner_curve_pts()),
        top_y = pts2[len(pts2)-1][1])
    concat(pts2, [[0.01, top_y], [0.01, base_thick], [pts2[0][0], pts2[0][1]]]);

// ------- Model (also punch the top opening so the outer cap doesn't remain) -------
module bottle_solid() {
    difference() {
        // outer body (rotate_extrude makes a top cap; we'll remove it with a short hole)
        rotate_extrude(angle=360) polygon(points = close_outer_profile());

        // subtract inner cavity + top mouth hole (to remove the “cap” at TOP_Z)
        union() {
            rotate_extrude(angle=360) polygon(points = close_inner_profile());
            translate([0,0,TOP_Z - lip_height])
                cylinder(h = lip_height + 0.6, r = INNER_NECK_R, $fn=$fn); // clean opening
        }
    }
}

color("gainsboro") bottle_solid();

// Debug: view 2-D curves if you want to tweak shoulders
// *stroke(vec2ize(outer_curve_pts()), width=0.7);
// *stroke(vec2ize(inner_curve_pts()), width=0.7, color="red");
