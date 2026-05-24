include <BOSL2/std.scad>
include <BOSL2/skin.scad>
include <BOSL2/rounding.scad>
include <BOSL2/walls.scad>

// ============================================================
//  Sports coupe body  -  built from skinned cross sections
//  X = length (nose at +X), Y = width, Z = height
// ============================================================

$fn = 64;

// ---- overall dimensions (mm, ~ real-car scale) -------------
L      = 4300;   // overall length
W      = 1900;   // overall width (at widest)
H      = 1280;   // overall height

// A body cross section is a rounded polygon in the Y-Z plane.
// We describe each station along X by:
//   x      : longitudinal position
//   halfw  : half width of body at this station
//   zlo    : bottom of body (ground clearance line)
//   zhi    : top of body shell (belt/shoulder line, NOT roof)
//   topr   : top corner rounding
//   botr   : bottom corner rounding
//   tuck   : how much the lower edge tucks inboard (rocker)

// Cross-section generator: a closed path in [Y,Z]
// halfw : max half-width (at shoulder/belt)
// zlo   : bottom of body
// zhi   : top of body shell
// tuck  : inboard offset of the lower (rocker) edge
// jf    : joint fraction for corner softness
function body_section(halfw, zlo, zhi, tuck, jf=0.26) =
    let(
        y  = halfw,
        yb = halfw - tuck,
        ht = zhi - zlo,
        scale = min(y, ht),
        j  = scale * jf,
        pts = [
            [ -yb, zlo ],                 // bottom-left (rocker)
            [ -y,  zlo + ht*0.42 ],       // max width point, left
            [ -y*0.93, zhi ],             // shoulder, left
            [  y*0.93, zhi ],             // shoulder, right
            [  y,  zlo + ht*0.42 ],       // max width point, right
            [  yb, zlo ],                 // bottom-right (rocker)
        ]
    )
    round_corners(pts, method="smooth", joint=j, k=0.7, closed=true, $fn=24);

// stations from tail (x=0) to nose (x=L)
// {x, halfw, zlo, zhi, tuck}
// Underbody (zlo) kept high & nearly flat across the front so the
// nose reads as a blunt fascia rather than a knife edge.
stations = [
    [   0,  560, 480, 760, 130],   // tail end (truncated, fuller)
    [ 150,  780, 430, 795, 170],   // rear bumper
    [ 600,  920, 360, 815, 230],   // rear haunch
    [1050,  950, 330, 810, 250],   // over rear wheels (widest)
    [1500,  910, 320, 795, 240],   // mid / door lower
    [1950,  880, 315, 770, 230],   // mid
    [2450,  885, 315, 745, 230],   // front of doors
    [2900,  905, 320, 705, 230],   // front fender start
    [3250,  935, 325, 665, 230],   // over front wheels
    [3650,  905, 330, 605, 215],   // hood / fender taper
    [3950,  860, 340, 565, 185],   // hood front
    [4150,  790, 350, 540, 150],   // nose top
    [4280,  690, 360, 520, 120],   // nose face (blunt)
    [4300,  600, 380, 510, 100],   // front lip (rounded cap)
];

module body_shell() {
    profiles = [
        for (s = stations)
            let(sec = body_section(s[1], s[2], s[3], s[4]))
            [ for (p = sec) [ s[0], p.x, p.y ] ]   // place into X
    ];
    skin(profiles, slices=14, method="reindex", sampling="length");
}

// ---- Greenhouse / cabin -----------------------------------
// A separate skinned volume sitting on the body's shoulder line.
//   x, halfw(base), zbelt(bottom of glass), zroof(top), roofw(half width at roof)
green_stations = [
    [ 650, 760, 760, 770,  640],   // start of rear deck blend (very low)
    [1000, 800, 775, 870,  600],   // rear glass base rises
    [1350, 820, 790,1040,  560],   // C-pillar
    [1550, 824, 795,1130,  535],   // rear roof shoulder
    [1700, 825, 800,1190,  520],   // approaching roof peak
    [1875, 823, 800,1235,  515],   // peak (rear half)
    [2050, 820, 800,1250,  515],   // roof peak
    [2225, 815, 798,1245,  525],   // peak (front half)
    [2400, 805, 795,1230,  540],   // front of roof
    [2550, 790, 785,1160,  560],   // upper windshield
    [2700, 770, 775,1080,  580],   // A-pillar / windshield top
    [2950, 720, 740, 870,  620],   // windshield base / cowl
    [3150, 660, 710, 760,  600],   // cowl fade into hood
];

function green_section(halfw, zbelt, zroof, roofw) =
    let(
        ht = zroof - zbelt,
        scale = min(halfw, max(ht,1)),
        // pull the two roof points toward centre so the smooth rounding
        // merges them into a continuous crown (no flat top ridge)
        rw = roofw * 0.78,
        // roof-corner joint must fit BOTH the short top edge (~rw) and the
        // slanted edge down to the shoulder (~scale); take the smaller.
        rj = min(rw*0.42, scale*0.30)
    )
    (ht < 30)
        // nearly flat (deck) -> simple low arc, gentle rounding
        ? round_corners(
            [[-halfw,zbelt],[-roofw,zbelt+20],[roofw,zbelt+20],[halfw,zbelt]],
            method="smooth", joint=scale*0.15, k=0.7, closed=true, $fn=24)
        : round_corners(
            [[-halfw,zbelt],[-halfw*0.98,zbelt+ht*0.4],
             [-rw,zroof],[rw,zroof],
             [halfw*0.98,zbelt+ht*0.4],[halfw,zbelt]],
            method="smooth",
            joint=[scale*0.16, scale*0.16, rj, rj, scale*0.16, scale*0.16],
            k=0.9, closed=true, $fn=32);

module greenhouse() {
    profiles = [
        for (s = green_stations)
            let(sec = green_section(s[1], s[2], s[3], s[4]))
            [ for (p = sec) [ s[0], p.x, p.y ] ]
    ];
    skin(profiles, slices=14, method="reindex", sampling="length");
}

// ============================================================
//  Wheel positions & arches
// ============================================================
// Wheel centres (X), centre height (Z), and arch radius.
front_x   = 3300;
rear_x    = 1000;
wheel_z   = 300;      // hub centre height
arch_r    = 320;      // wheel-arch radius (fits under fender crown)
track_h   = 1000;     // half-distance between left/right arch centres (outboard)

// A wheel-arch cutter: a cylinder (axis along Y) bores the arched
// opening, but its TOP is capped at arch_top so it never slices
// vertically through the hood/fender and detaches the body.
module arch_cutter(cx, arch_top) {
    intersection() {
        translate([cx, 0, wheel_z])
            rotate([90,0,0])
                cylinder(h = W+200, r = arch_r, center=true, $fn=72);
        // keep only the part at or below arch_top
        translate([cx, 0, arch_top - 2000])
            cube([arch_r*3, W+300, 4000], center=true);
    }
}

// ============================================================
//  Glass openings (cut into the greenhouse)
// ============================================================
// Side window (DLO): a lozenge cut through the cabin sides.
// Profile is defined in X-Z then extruded along Y to pierce both sides.
module side_glass_cutter() {
    win = round_corners(
        [[1500, 820],   // rear lower
         [1480, 980],   // C-pillar base
         [1820,1130],   // top rear
         [2450,1140],   // top front
         [2680, 980],   // A-pillar
         [2520, 820],   // front lower
        ],
        method="smooth", joint=60, k=0.7, closed=true, $fn=24);
    translate([0, W/2+100, 0])
        rotate([90,0,0])
            linear_extrude(height=W+200)
                polygon([for(p=win)[p.x,p.y]]);
}

// Windshield + backlight: cut the front and rear glass planes.
module windshield_cutter() {
    // a thin slab raked back, spanning the cabin width
    multmatrix(m = [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
    translate([2680, 0, 980])
        rotate([0,32,0])
            cube([60, 1300, 700], center=true);
}
module backlight_cutter() {
    translate([1500, 0, 980])
        rotate([0,-38,0])
            cube([60, 1300, 700], center=true);
}

// ============================================================
//  Front fascia: grille cavity + hex mesh + side intakes
// ============================================================
// The nose face sits near x = NOSE_X, tilted back slightly at top.
NOSE_X = 4250;

// A recess cutter for the main grille (rounded trapezoid pocket)
module grille_cavity() {
    outline = trapezoid(h=460, w1=1160, w2=940, rounding=80, $fn=32);
    translate([NOSE_X, 0, 500])
        rotate([90,0,90])
            linear_extrude(height=180, center=true)
                polygon(path2d(outline));
}

// Hex mesh grille panel, oriented to face forward (+X), set into the cavity
module grille_mesh() {
    outline = trapezoid(h=440, w1=1130, w2=920, rounding=70, $fn=32);
    translate([NOSE_X-25, 0, 500])
        rotate([90,0,90])
            hex_panel(outline, strut=18, spacing=84, frame=24, h=90);
}

// Lower outer recesses flanking the grille (smooth fog-lamp/intake scoops)
module lower_recess_cavity(side) {   // side = +1 left, -1 right
    translate([NOSE_X+5, side*690, 470])
        rotate([90,0,90])
            scale([1,0.62,1])
                cylinder(h=150, r=150, center=true, $fn=40);
}

// Headlight recesses: swept teardrop pockets on the front corners
module headlight_cavity(side) {   // side = +1 left, -1 right
    hull() {
        translate([NOSE_X-30, side*640, 640])
            rotate([90,0,90]) scale([1,0.5,1]) cylinder(h=120,r=120,center=true,$fn=36);
        translate([4050, side*820, 640])
            rotate([90,0,90]) scale([1,0.5,1]) cylinder(h=120,r=70,center=true,$fn=36);
    }
}

// ============================================================
//  Side mirrors (on short stalks at the A-pillar base)
// ============================================================
module mirror(side) {   // side = +1 left, -1 right
    mx = 2800;          // X near base of A-pillar
    my = side * 760;    // anchor set inside the body skin so the stalk fuses
    mz = 780;           // height (just below beltline)
    // triangular stalk fairing growing out of the body
    hull() {
        translate([mx, my, mz-25])
            sphere(r=48, $fn=24);
        translate([mx-25, my + side*170, mz+30])
            sphere(r=30, $fn=24);
    }
    // mirror head: flattened aerofoil shell facing back-outboard
    translate([mx-40, my + side*205, mz+45])
        rotate([0,0,side*14])
            scale([0.62,1.05,0.55])
                sphere(r=120, $fn=40);
}

// Front splitter lip: a thin blade hugging the underside of the fascia,
// projecting only slightly forward.
module splitter() {
    outline = trapezoid(h=130, w1=1640, w2=1480, rounding=30, $fn=24);
    // place just below the grille, set back so it barely projects past nose
    translate([NOSE_X-90, 0, 365])
        rotate([90,0,90])
            linear_extrude(height=70)
                polygon(path2d(outline));
}

// ============================================================
//  Assembly
// ============================================================
module car_body() {
    difference() {
        union() {
            body_shell();
            greenhouse();
        }
        // four wheel arches (cutters span full width, so one call per axle)
        arch_cutter(front_x, 640);
        arch_cutter(rear_x, 700);
        // glasshouse openings
        side_glass_cutter();
        // front fascia recesses
        grille_cavity();
        lower_recess_cavity(1);
        lower_recess_cavity(-1);
        headlight_cavity(1);
        headlight_cavity(-1);
    }
    // grille mesh (added back into the recess)
    grille_mesh();
    // front splitter
    splitter();
    // mirrors
    mirror(1);
    mirror(-1);
}

car_body();
