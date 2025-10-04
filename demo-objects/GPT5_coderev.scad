include <BOSL2/std.scad>;
$fn = 160;

// ---------------- Customizer ----------------
bottle = 2;               // [0:200,1:375,2:500,3:700,4:750]
wall   = 4;

// ---------------- Presets from diagram ----------------
dia      = [66, 77, 84, 90, 92];       // body width (mm)
h        = [148,175,197,218,220];      // overall height (mm)
neck_od  = [18.5,18.5,18.5,21.5,21.5]; // mouth OD (mm)

// ---------------- Tunables (no magic numbers) ----------
base_thick   = 6;                   // solid base
base_fillet  = 0.08*dia[bottle];    // bottom outside fillet radius
shoulder_at  = 0.70*h[bottle];      // y where shoulder begins (from bottom)
neck_h       = 0.22*h[bottle];      // straight neck height
lip_h        = 2;                   // vertical lip at very top
lip_bead     = 0.75;                // small outward bead
// Shoulder curvature (two arcs; tweak for style)
dR           = dia[bottle]/2 - neck_od[bottle]/2;
OR1 = max(dR*0.90, 12);  OA1 = 65;  // outer shoulder arc 1 (R, deg)
OR2 = max(dR*0.45,  7);  OA2 = 45;  // outer shoulder arc 2
IR1 = max((dR-wall)*0.90, 10); IA1 = 63;  // inner shoulder (match wall)
IR2 = max((dR-wall)*0.45,  5); IA2 = 43;

// ---------------- Derived ----------------
Rbody   = dia[bottle]/2;
Rneck   = neck_od[bottle]/2;
Rbody_i = Rbody - wall;
Rneck_i = max(Rneck - wall, 1);

y0          = 0;
y_shoulder  = shoulder_at;
y_neck_base = h[bottle] - neck_h;
y_lip_base  = h[bottle] - lip_h;

eps = 0.01;

// ---------------- OUTER path ----------------
outer = turtle([
    // start at outer bottom corner minus fillet
    "move", Rbody - base_fillet,
    "setdir", 0,
    "arcright", base_fillet, 90,      // bottom fillet -> heading 270 or 0 depending on BOSL2; force:
    "setdir", 90,                     // go vertical from here

    "untily", y_shoulder,             // straight body

    // shoulder bends inward
    "arcleft", OR1, OA1,
    "arcleft", OR2, OA2,

    "setdir", 90,
    "untily", y_lip_base,             // straight neck to just under top

    // Tiny outward bead and lip
    "setdir", 0,  "move", lip_bead,   // small radial bump
    "setdir", 90, "untily", h[bottle] // up to top
]);

// ---------------- INNER path ----------------
inner = turtle([
    // start above solid base with smaller fillet
    "move", max(Rbody - base_fillet - wall, eps),
    "setdir", 0,
    "arcright", max(base_fillet - wall, eps), 90,
    "setdir", 90,
    "untily", max(y_shoulder - wall, base_thick),  // inner body rise

    // inner shoulder matching outer minus wall
    "arcleft", IR1, IA1,
    "arcleft", IR2, IA2,

    "setdir", 90,
    "untily", max(y_lip_base - max(wall*1.2, 1.5), base_thick), // stop below lip
    "setdir", 0, "untilx", Rneck_i                              // ensure inner neck radius
]);

// ---------------- Model ----------------
diff() {
    // outer shell
    rotate_sweep(outer, 360);

    // inner cavity + mouth drill (to avoid closed top, if any)
    tag("remove") {
        up(base_thick) rotate_sweep(inner, 360);
        up(y_lip_base) cylinder(h=lip_h+0.6, r=Rneck_i, $fn=$fn);
    }
}

// ---------- Optional debug ----------
// *color("orange") stroke(outer, width=0.6);
// *color("dodgerblue") back(wall) stroke(inner, width=0.6);
