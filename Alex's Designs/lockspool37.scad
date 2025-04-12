/*
LockSpool: Parametric, reusable (ONE part printed twice)
by Alex Matulich
Version 3.7, September 2024

This design on Thingiverse: https://www.thingiverse.com/thing:5234368
This design on Prusaprinters: https://www.prusaprinters.org/prints/129989

Lockspool is a reusable filament spool made from a single part printed twice, and joined together with a quick twist, with a snap-lock to hold it in place. The design can be customized to fit any spool-less filament refill coil by adjusting just six parameters.

This design produces spools compatible with MasterSpool (750 g), SlantSpool (1 kg), Filaments.ca EconoFil (1 kg), and other filament refill coils. Parameter values are shown in the table below and in the comments.

Print settings:
* 3 perimeters
* 0 top and bottom layers
* 20% cubic infill
* 0.30 mm layer height ("DRAFT" preset in Slic3r / PrusaSlicer).

Improvements over original and other MasterSpool designs:
* Both halves are the same. Print just one part as many times as you need.
* Quick twist to connect the halves, no multiple turns of a threaded part.

Improvements over SlantSpool:
* Snap-lock mechanism to keep the two halves in place.
* Easy to replace the tie-wraps to remove the refill for storage.
* No large gaps in the hub, the better to wind your own spool if needed.
* Parametric design. CAD file included (you're looking at it).
* Better CC-BY-SA license (SlantSpool has a "no derivatives" restriction).

Improvements over both MasterSpool and SlantSpool:
* Lighter weight, less material, and faster printing (41% faster than original MasterSpool, 24% faster than SlantSpool, both of which use about 1/4 kg of filament just to print one spool!
* Can be printed without top or bottom layers, improving print speed even more while remaining strong.
* Multiple parts stack together neatly on a shelf.

COMPARISONS                 Filament (g)  Time
-------------------------------------------------
750 g refill:
  LockSpool x2, default slicer  181.2     9:40
  LockSpool x2, no top/bottom   165.9     8:02 (3 perimeters)
  LockSpool x2, no top/bottom   138.0     6:54 (2 perimeters)
  MasterSpool (both parts)      276.9    13:38
   https://www.thingiverse.com/thing:2769823
1 kg refill:
  LockSpool x2, default slicer  191.3    10:12
  LockSpool x2, no top/bottom   178.9     8:46
  SlantSpool x2                 255.1    11:28
   https://www.thingiverse.com/thing:2850604
  EconoFil (both parts)         173.7     8:12
   https://www.thingiverse.com/thing:2869973

MasterSpool dimensions from https://cdn.thingiverse.com/assets/f0/b6/80/63/be/MasterSpool_V4_information.pdf
SlantSpool dimensions from https://www.thingiverse.com/thing:2850604
Other dimensions measured from online models.

            Master  Slant  Econ- Fus- SUN- Inland  Para- LeeFung  Prusa- Matter-
Dimension    Spool  Spool  oFil  ion  LU   /eSun   mount 1kg/800g  ment  Hackers
--------------------------------------------------------------------------------
  spool_dia    198   200   200   198  200    200    200    200    200     175
  hub_dia      102   100   74.5   76   79     90    100 90(b)/103  93      82
  bearing_dia  52.5   52   47(a) 48(a) 52     52     52     53     52      52
  inner_width  46.7   62    58    67   57 55.5/57.6  70 57(b)/46   65      62
  numslots       3     4     4     3    3      4(c)   3      3    4(e)      4
  hubindent      3     3     2     2   0(d)    3      3      3      3       2
  hubwall       10    10     7     7    6     10     10    9/10    10       7

(a) EconoFil and Fusion Filaments bearing diameter is made smaller here to compensate for internal structure of LockSpool hub design.
(b) Lee Fung dimensions based on manufacturer's spool dimensions modified by their comments on https://www.thingiverse.com/thing:3582542/comments
(c) Inland and eSun spools are nearly identical. eSun inner_width works for both.
(d) The reusable spool provided by SUNLU is designed to be loose so that tie-wrap channels are not needed. So it is here. If you want channels, use values bearing_dia=50, hubindent=2, hubwall=7
(e) Slots are not needed for Prusament unless you want to remove the coil from the spool.
*/

// ---------- normal settings (refer to table above) ----------

label = "Prusament"; // label for spool hub, leave blank to include only dimensions
spool_dia = 200;        // overall spool diameter, typically 198-200
hub_dia = 93;           // spool hub diameter (so the donut fits around it)
bearing_dia = 52;       // bearing hole diameter, typically 52 except for narrow hubs
inner_width = 65;       // height of refill donut when laying flat on a table
numslots = 4;           // Number of tie-wrap slots (use 3 if you set hubindent to 0)
hubindent = 3;          // depth of tie-wrap slot in the hub
hubwall = 10;           // thickness of hub wall

// ---------- advanced settings ----------

module dummy() {}       // force customizer to stop looking for settings here

display = "print";      // what to display (print, print mini, lock, snap, animate, assembly - all but "print" and "print mini" (for Prusa mini buildplate) are for visualization and debugging)

holechamfer = 1.0;      // chamfer (mm) for holes - this causes the preview to be sluggish; set to 0 to speed up preview, use 1.0 for printing.
chamfer = 1;            // other structural chamfer (no effect on speed)

flange_thickness = 5.0; // MasterSpool & EconoFil=5.6, others=5 (doesn't matter)
slotwidth = 12;         // accommodate tie wraps 2.6 - 8 mm wide (2 mm clearance on each side)
hclearance = 0.25;      // horizontal (radial) clearance for lock pins
vclearance = 0.5;       // vertical clearance between lock pin and lock hole
filament_hole = 3.2;    // diamter of rim-concentric hole for filament storage
fslotwidth = 5;         // horizontal width of filament slot in the hub
fslotlen = 4;           // length of filament slot opening
bearing_min_contact = 5; // minimum contact width of bearing
ehole_side_clearance_angle = 2; // extra angular width on each side of lock pin entry hole
holeanglespace = 5;     // angular space between flange holes (degrees)

// we can violate the 45-degree overhang rule just a little bit
lockoverhang = 44;      // overhang angle (from horizontal) for locking pins
springoverhang = 40;    // overhang angle for snap latch spring
springperimeters = 4;   // number of perimeters for spring (3-5)

// font for dimensioning label on underside
labelfont = "Liberation Mono:style=Bold";
sidefontsize = 4.5;     // font size for side label (top label size is calculated)
label_top = false;      // whether to engrave a label on the top surface
label_side = true;      // whether to engrave a label on the side

filament_winding_hole = true; // whether to add a the hole for starting filament winding

// --------- initialization ----------

pdx = min(1, hubwall/10);   // horizontal distance scaling unit for locking pin profile
pdy = tan(lockoverhang)*pdx; // vertical distance scaling unit for locking pin profile

rimthickness = max(4,2.5+holechamfer); // minimum outer rim thickness after cutting holes
hubht = 0.5*inner_width;    // height of hub above flange
slotr = 0.5*slotwidth;      // tie-wrap slot "radius" (half of slot width)
ohubr = 0.5*hub_dia;        // outer radius of hub
ihubr = ohubr - hubwall;    // inner radius of hub
flangr = 0.5*spool_dia;     // flange radius
bearingr = 0.5*bearing_dia; // bearing radius
bearing_chamfer = max(0.6, min(2, ohubr-16*pdx-bearingr-holechamfer-0.5)); // bearing hole bevel
halfspoolwid = 0.5*inner_width + flange_thickness; // half of spool outer width
topfontsize = min(5, hubwall-3); // top label font size

// arc lengths

pinarc = let(aslot = asin(slotr/ohubr)) (360-6*aslot) / (3*numslots); // lock pin
equalarc = 360/numslots/3 - 2*ehole_side_clearance_angle; // all 3 holes excl clearance
slotarc = hubindent > 0 ? // arc size of hub slot hole
    2*asin(slotr/ohubr) + pinarc/2+2*ehole_side_clearance_angle
    : equalarc;
filholearc = hubindent > 0 ? // arc size of filament slot hole
    2*(360/numslots - (180/numslots+pinarc/4) - 0.5*slotarc) - 2*holeanglespace - 3*ehole_side_clearance_angle
    : equalarc;
xholearc = hubindent > 0 ? // extra hole between slot hole and hub slot hole
    0.5*(360/numslots - filholearc - slotarc)
    : equalarc; 

/* locking pin
 _______
/       \
|        |
|       /
|     /
|    |
|    |
-----+_--- <origin
|     | 
|     |
 \    |
   \  |
     \|
*/
dvclear = vclearance-2*hclearance*pdy;

lockpin_profile = [
    [-hclearance,0.5], [-hclearance+0.5,0], [2*pdx,0], [2*pdx,-12], [-6*pdx,-2], // bottom attachment
    [-6*pdx,10*pdy], [-4*pdx,12*pdy], [2*pdx,12*pdy], [4*pdx-hclearance,10*pdy], [4*pdx-hclearance,8*pdy], [-hclearance, 4*pdy]
];

lhc = hclearance-0.02; // lock hole horizontal clearance (at hub wall) to match entryhole profile

lockhole_profile = [
    [-4*pdx+hclearance, -hubht+0.01], [4*pdx-chamfer+lhc, -hubht+0.01], [4*pdx+lhc,-hubht+chamfer], [4*pdx+lhc,-(9+3*hclearance)*pdy], [4*pdx+3*hclearance, -(8+2*hclearance)*pdy+dvclear], [-4*pdx+hclearance, dvclear]
];

entryhole_profile = [
    [-6*pdx-3*hclearance,-halfspoolwid-1], [4*pdx+3*hclearance,-halfspoolwid-1], [4*pdx+3*hclearance,1], [-6*pdx-3*hclearance, 1]
];

// ---------- end of initialization ----------

// ---------- render the part ----------

if (display == "print") {
    halfspool();
} else if (display == "print mini") { // truncated for Prusa Mini 180x180 build plate
    arc = acos(180/spool_dia);
    for(a=[0:90:271]) rotate([0,0,a]) minkowski() {
        translate([0,0,chamfer]) linear_extrude(flange_thickness-2*chamfer) let(r=spool_dia/2, x=r*cos(arc)-chamfer, y=r*sin(arc)-chamfer) polygon(points=[[x,-y], [x-6+2*chamfer, -y+5], [x-6+2*chamfer, y-5], [x,y]]);
        rotate_extrude(angle=360, $fn=4) polygon(points=[[0,chamfer], [chamfer,0], [0,-chamfer]]);
    }
    halfspool(true);
} else if (display == "lock") {
    translate([0,0,-inner_width/2-flange_thickness]) difference() {
        halfspool();
        cube([spool_dia+2, spool_dia+2, halfspoolwid+24], center=true);
    }
    #translate([0,0,inner_width/2+flange_thickness]) rotate([180,0,8]) difference() {
        halfspool();
        cube([spool_dia+2, spool_dia+2, halfspoolwid+24], center=true);
    }
} else if (display == "snap")
    difference() {
        union() {
            translate([0,0,-0.01])halfspool();
            color("silver") difference() {
                translate([0,0,2*halfspoolwid]) rotate([180,0,0]) halfspool();
                translate([0,0,2*halfspoolwid+1]) cube([spool_dia+2, spool_dia+2, 2*halfspoolwid], center=true);
            }
        }
        cube([spool_dia+2, spool_dia+2, halfspoolwid], center=true);
        translate([-spool_dia, -spool_dia/2-1,-1])
            cube([spool_dia, spool_dia+2, halfspoolwid+20]);
    }
else if (display == "animate") {
    time_pos = [40, 30, 20, 10, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 10, 20, 30, 40];
    time_ang = let(pa5=pinarc+5) [pa5, pa5, pa5, pa5, pa5,
                3*pa5/4, pa5/2, pa5/4, 0, 0, pa5/4, pa5/2, 3*pa5/4,
                pa5, pa5, pa5, pa5, pa5];
    halfspool();
    t=round(len(time_pos)*$t);
    translate([0,0,2*halfspoolwid+time_pos[t]])
        rotate([0,0,time_ang[t]])
            rotate([180,0,0]) halfspool();
} else if (display == "assembly") {
    aslot = asin(slotr/ohubr)+0;
    pa_c = pinarc+2*ehole_side_clearance_angle;
    halfspool();
    translate([0,0,2*halfspoolwid]) rotate([180,0,pa_c+4/*-42*/]) color("pink") halfspool();
    //rotate([0,0,aslot+pa_c/2-6]) translate([-ohubr,0,halfspoolwid]) cube([slotwidth,slotwidth,slotwidth], center=true);
    //rotate([0,0,0]) translate([-ohubr,0,halfspoolwid]) cube([slotwidth,slotwidth,slotwidth], center=true);
}

// ========== modules ==========

/*
//color("cyan") correctionring(1);
module correctionring(rdiff) {
    rnew = bearingr - rdiff;
    chamfer=bearing_chamfer;
    rotate_extrude(angle=360, $fn=144) translate([bearingr-0.1,0,0])
    polygon(points=[
        [chamfer,0], [chamfer-rdiff,0], [chamfer-2*rdiff,chamfer], [chamfer-2*rdiff, chamfer+4], [0, chamfer+4], [0,chamfer] ]);
}
*/

// ---------- half spool assembly ----------

module halfspool(mini=false) {
    difference() {
        union() {
            difference() {
                union() {
                    halfspool_with_cutouts(mini);
                    translate([0,0,halfspoolwid]) // add lock pins
                        for(a=[0:360/numslots:359]) rotate([0,0,a-pinarc])
                            lockpin();
                }
                translate([0,0,halfspoolwid]) // subtract lock grooves
                    for(a=[0:360/numslots:359]) rotate([0,0,a])
                        lockhole(180/numslots-pinarc/2-3);
            }
            // add in solid structure for filament slot
            for(a=[0:360/numslots:359]) rotate([0,0,a]) filamentslotbody();
        }
        // subtract filament slot hollow volume, snap lock groove
        for(a=[0:360/numslots:359]) rotate([0,0,a]) {
            filamentslothole();
            snaplock(hole=true);
        }
        // subtract label from top
        if (label_top) toplabel();
        if (label_side) sidelabel();
    }
    // add one snap lock latch (just one, not 3 or 4)
    snaplock(hole=false);
}

// ---------- spool flange with cutouts ----------

module halfspool_with_cutouts(mini=false) {
    holemaxr = flangr - rimthickness;

    difference() {
        if (mini)
            intersection() {
                blankhalfspool();
                translate([-90,-90,-1]) cube([180,180,2*hubht]);
            }
        else
            blankhalfspool();

        for (a=[0:360/numslots:359]) {
            // hole at filament slot
            rotate([0,0,a]) flange_hole(filholearc, ohubr, ohubr+4, 0.5*(ohubr+flangr-3), holemaxr, 0.5*filholearc, 0.8*filholearc);
            // hole at hub slot
            rotate([0,0,a+(hubindent>0?180/numslots+pinarc/4:equalarc+ehole_side_clearance_angle)+ehole_side_clearance_angle]) if (hubindent>0) flange_hole(slotarc, ohubr-hubindent, ohubr+3-hubindent, 0.5*(ohubr+flangr-3), holemaxr, 0.8*slotarc, 0.7*slotarc, halfspoolwid); else extrahole();
            // extra hole
            rotate([0,0,a+(hubindent>0 ? 0.5*(filholearc/2+180/numslots+pinarc/4-slotarc/2+ehole_side_clearance_angle) : 2*equalarc+4*ehole_side_clearance_angle)]) extrahole();
            // pin entry hole near bearing
            rotate([0,0,a+180/numslots]) entryhole();
            // filament storage tube near rim
            translate([0,0,flange_thickness/2]) rotate([0,0,a-filholearc/2]) curved_hole(filament_hole/2, holemaxr, filholearc);
            // extra hole in hub for starting a filament winding
            if (filament_winding_hole)
                rotate([0,0,a+180/numslots+10]) translate([ohubr,0,0.5*hubht+flange_thickness]) straight_hole(filament_hole/2, 2*hubwall, true);
        }
    }
    module extrahole() {
        flange_hole(xholearc, ohubr+1+holechamfer, 0.5*(ohubr+flangr), 0.5*(ohubr+flangr), holemaxr, xholearc/2, 0.5*xholearc, outsharp=0.99);
    }
}

// ---------- blank half-spool (bearing, flange, and hub) ----------

module blankhalfspool() {
    bearinght = max(bearing_min_contact, flange_thickness + bearing_chamfer)+0.3;
    bearingoutbevel = min(bearinght=flange_thickness, bearing_chamfer);
    rotate_extrude(angle=360, convexity=6, $fn=144) polygon(points = [
    
        [bearingr+bearing_chamfer, 0],
        [bearingr, bearing_chamfer],
        [bearingr, bearinght],
        [bearingr+2, bearinght],
        [bearingr+2, flange_thickness+bearingoutbevel],
        [bearingr+3+bearingoutbevel, flange_thickness],
    
        [ihubr-chamfer, flange_thickness],
        [ihubr, flange_thickness+chamfer],
        [ihubr, halfspoolwid-chamfer],
        [ihubr+chamfer, halfspoolwid],
        [ohubr-chamfer, halfspoolwid],
        [ohubr-0.33*chamfer, halfspoolwid-0.33*chamfer],
        [ohubr, halfspoolwid-chamfer],
        [ohubr, flange_thickness+chamfer],
        [ohubr+0.33*chamfer, flange_thickness+0.33*chamfer],
        [ohubr+chamfer, flange_thickness],
        
        [flangr-chamfer, flange_thickness],
        [flangr, flange_thickness-chamfer],
        [flangr, chamfer],
        [flangr-chamfer, 0]
    ]);
}

// ---------- enclosure of internal space behind filament slot in hub ----------

fswall = 2;     // wall thickness of space behind filament slot
fsht = min(18, halfspoolwid-14*pdy-2); // internal height of space behind slot
fsarc = 180/numslots-6; // arc length of hollow space behind slot

module filamentslotbody(ht=4) {
    translate([0,0,2]) rotate([0,0,-fsarc/2]) rotate_extrude(angle=fsarc, convexity=4, $fn=96)
        translate([ohubr-ht-2*fswall,0,0]) square(size=[ht+1.5*fswall, fsht]);

}

// ---------- modules related to locking pin (including cutouts) ----------

// locking pin

module lockpin() {
    dr = hubwall/10;
    rotate_extrude(angle=pinarc, convexity=4, $fn=144) translate([ohubr-hubwall,0,halfspoolwid])
        polygon(points=lockpin_profile);
}

// groove to secure locking pin

module lockhole(holearc) {
    rotate([0,0,0]) rotate_extrude(angle=holearc+2, convexity=4, $fn=144) translate([ohubr-hubwall,0,0]) polygon(points = lockhole_profile);
}

module snaplock(hole=false) {
    pwid = 0.45; // width of a perimeter 
    wid = pwid*springperimeters;
    snapwid = 8;
    thispinht = halfspoolwid + lockpin_profile[4][1] - 1;
    otherpinht = halfspoolwid - lockpin_profile[5][1];
    r = ihubr + lockpin_profile[4][0] - 2*hclearance;
    anginc = asin(1 / r);
    arc = min( (otherpinht-flange_thickness)/tan(springoverhang)*360/(2*PI*r), pinarc+4*anginc)-1;
    snapht = thispinht - flange_thickness;
    starta = atan((2+wid)/(r-wid));
    enda = starta + arc;
    dz = tan(springoverhang);
    na = arc / anginc;
    if (hole) {
        hht = lockpin_profile[6][1] - lockpin_profile[3][1] + 1;
        zoff = halfspoolwid + lockpin_profile[3][1];
        translate([0,0,zoff]) {
            rotate([0,0,-4*anginc]) translate([hclearance,0,0]) latch(hht);
            rotate([0,0,1.5*anginc]) translate([hclearance,0,0]) latch(hht);
        }
    } else {
        pts = [
            [r+2, wid], [ihubr+1, wid], [ihubr+1, 0], [r+2, 0],
            for(a=[-90:-10:-179]) [(2+wid)*(1+cos(a))+r-wid-pwid/2, (2+wid)*(1+sin(a))],
            for(a=[starta:3:arc]) [(r-wid)*cos(a), (r-wid)*sin(a)],
            for(a=[arc:-3:starta]) [r*cos(a), r*sin(a)],
            for(a=[180:10:269]) [2*(1+cos(a))+r-pwid/2, 2*(1+sin(a))+wid]
        ];
        color("silver") rotate([0,0,-arc+4*anginc])
        difference() {
            union() {
                translate([0,0,flange_thickness-1])
                    linear_extrude(snapht+1, convexity=6) polygon(points=pts);
                translate([0,0,flange_thickness-1])
                    rotate([0,0,arc]) latch(snapht+2);
            }
            for(n=[na+4:-1:1]) let(a=n*anginc, z=otherpinht+dz*(n-na))
                rotate([0,0,a]) translate([r-wid-1,0,z]) rotate([0,90,0])linear_extrude(wid+4) polygon(points=[[-1.2*dz, 1.2], [hubht,1.2], [hubht,0], [0,0]]);
        }
    }
    module latch(xht, outdent=1.5) {
        latchpts = let(rlatch = r+outdent) [
            for(a=[-4*anginc:anginc:4*anginc]) [(r-wid)*cos(a), (r-wid)*sin(a)],
            [(r-wid)*cos(4*anginc), (r-wid)*sin(4*anginc)],
            [rlatch*cos(0.5*anginc), rlatch*sin(0.5*anginc)],
            [rlatch*cos(-0.5*anginc), rlatch*sin(-0.5*anginc)]
        ];
        linear_extrude(xht) polygon(points=latchpts);
    }
}
//snaplock(36.25);
//snaplock(36.25, true);

// ---------- modules for cutouts ----------

// generalized flange hole, modeled as a sort of flared spoke with bezier cubic curves on the corners
// angle = angular span of hole
// r1 = minimum radius
// r2 = second radius where the inner corner curves end
// r3 = third radius where the outer corner curves start
// r4 = maximum radius of hole
// r1arc = arc length of inner edge (r1) of hole that conforms to a circle (smaller than angle, to allow for curved corners)
// r4arc = arc length of outer edge (r4) of hole that conforms to a circle)
// ht = height of material in which to make this hole
// insharp = sharpness of curves near hub
// outsharp = sharpness of curves near rim
// test = set to true to visualize the control points on the shape
//        for example:
//        flange_hole(20, 47, 55, 75, 100, 5, 15, true);

module flange_hole(angle, r1, r2, r3, r4, r1arc, r4arc, ht=flange_thickness, insharp=0.9, outsharp=0.75, test=false) {
    ang = 0.5*angle;    // half of angular sweep
    r1a = 0.5*r1arc;    // half arc at r1
    r4a = 0.5*r4arc;    // half arc at r4
    sharp1 = insharp;   // sharpness at inner corners
    sharp4 = outsharp;  // sharpness at outer corners
    midx = 0.5*(r1+r4);
    // bezier control points
    cp1 = [
        [r1*cos(r1a)-midx, r1*sin(r1a)],
        let(da = sharp1*(ang-r1a), rn = r1/cos(da)) [rn*cos(r1a+da)-midx, rn*sin(r1a+da)],
        let(rn = r1+(1-sharp1)*(r2-r1)) [rn*cos(ang)-midx, rn*sin(ang)],
        [r2*cos(ang)-midx, r2*sin(ang)]
    ];
    cp2 = [
        [r3*cos(ang)-midx, r3*sin(ang)],
        let(rn = r3+sharp4*(r4-r3)) [rn*cos(ang)-midx, rn*sin(ang)],
        let(da = sharp4*(ang-r4a), rn = r4/cos(da)) [rn*cos(r4a+da)-midx, rn*sin(r4a+da)],
        [r4*cos(r4a)-midx, r4*sin(r4a)]
    ];
    cp3 = [
        [cp2[3][0], -cp2[3][1]],
        [cp2[2][0], -cp2[2][1]],
        [cp2[1][0], -cp2[1][1]],
        [cp2[0][0], -cp2[0][1]]
    ];
    cp4 = [
        [cp1[3][0], -cp1[3][1]],
        [cp1[2][0], -cp1[2][1]],
        [cp1[1][0], -cp1[1][1]],
        [cp1[0][0], -cp1[0][1]]
    ];
    polypoints = [
        if (r1a > 0) for(a=[-r1a:1:r1a]) [r1*cos(a)-midx, r1*sin(a)],
        for(t=[0:0.1:0.99]) bezier_point2d(t, cp1),
        for(t=[0:0.1:0.99]) bezier_point2d(t, cp2),
        if (r4a > 0) for(a=[r4a:-1:-r4a]) [r4*cos(a)-midx, r4*sin(a)],
        for(t=[0:0.1:1.01]) bezier_point2d(t, cp3),
        for(t=[0:0.1:1.01]) bezier_point2d(t, cp4)
    ];
    
    if (test) {
        translate([midx,0,0]) {
            linear_extrude(flange_thickness+1) polygon(points=polypoints);
            plotcp(cp1);
            plotcp(cp2);
            plotcp(cp3);
            plotcp(cp4);
        }
    } else {
        translate([midx,0,-0.01]) linear_extrude(ht+1.02) polygon(points=polypoints);
        if (holechamfer > 0) {
            xscl = (r4-r1+4*holechamfer) / (r4-r1);
            yscl = (cp2[1][1]+2*holechamfer) / cp2[1][1];
            translate([midx,0,holechamfer+0.01]) rotate([180,0,0]) linear_extrude(2*holechamfer, scale=[xscl,yscl]) polygon(points=polypoints);
            difference() {
                translate([midx, 0, flange_thickness-holechamfer]) linear_extrude(2*holechamfer, scale=[xscl,yscl]) polygon(points=polypoints);
                if(r1 < ohubr+1) {
                    cutdepth = ohubr+2*holechamfer-r1;
                    translate([0,0,flange_thickness-2*holechamfer]) rotate([0,0,-ang-3]) rotate_extrude(angle=angle+6, convexity=4, $fn=144) translate([ohubr-cutdepth+0.01,0,0]) square(size=[cutdepth,3*holechamfer]);
                }
            }
        }
    }
    module plotcp(cp) {
        for(i=[0:3]) color("red") translate([cp[i][0],cp[i][1],0]) cylinder(5, d=1);
    }

}

// entry hole for locking pin (through whole hub, enters from top or bottom)

module entryhole() {
    pa = pinarc + 2*ehole_side_clearance_angle;
    ha = 0.5*pa; // half arc
    or = ohubr - 6*pdx; // outer radius of hole (pin already clear by hclearance)
    ir = or - 10*pdx - hclearance; // inner radius of hole;

    cosha = cos(ha);
    sinha = sin(ha);

    x0=or*cosha;
    y0=or*sinha;
    x1=ir*cosha;
    y1=ir*sinha;

    midx = 0.5*(or+x1);

    translate([0,0,-1]) linear_extrude(halfspoolwid+2, convexity=4)
        entryholepolygon();
    if (holechamfer > 0) {
        sclx = (or-x1+4*holechamfer) / (or-x1);
        scly = (y0+2*holechamfer) / y0;
        translate([midx,0,holechamfer]) rotate([180,0,0]) linear_extrude(2, scale=[sclx,scly], convexity=4) translate([-midx,0,0]) entryholepolygon();
    }
    module entryholepolygon() {
        q=y0-y1;
        steps = 10;
        polygon(points=[
            for(a=[-ha:ha/steps:ha-0.01]) [or*cos(a), or*sin(a)],
            for(t=[0:0.05:0.99])
                bezier_point2d(t, [[x0,y0], [x0-hubwall/2,y0], [x1-q*sinha, y1+q*cosha], [x1,y1]]),
            for(a=[ha:-ha/steps:0.01-ha]) [ir*cos(a), ir*sin(a)],
            for(t=[0:0.05:0.99])
                bezier_point2d(t, [[x1,-y1], [x1-q*sinha, -y1-q*cosha], [x0-hubwall/2,-y0], [x0,-y0]])
        ]);
    }
}

// cutout for filament slot in the hub, including bevel and internal hollow space

module filamentslothole(ht=fslotlen, width=fslotwidth) {
    w = 0.5*width;
    xb = -flange_thickness; // bottom of slot
    xt = xb-ht;             // top of slot
    basew = w+(1-xb)/pdy;
    translate([ohubr-2*fswall-0.5*ht,0,0]) {
        rotate([0,90,0]) linear_extrude(2*fswall+1.5*ht, convexity=4)
            polygon(points=[
                [xt,0], [xt,w-1], [xt+1,w], [xb,w], [1,basew],
                [1,-basew], [xb,-w], [xt+1,-w], [xt,1-w]
            ]);
        translate([0,0,-1]) scale([0.618,1,1]) cylinder(4, r1=basew, r2=basew-4/pdy, $fn=32);
    }
    translate([0,0,2])
        rotate([0,0,-(fsarc-4)/2]) rotate_extrude(angle=fsarc-4, convexity=4, $fn=96)
            translate([ohubr-fswall-ht, 0, 0])
                square(size=[ht, fsht-1]);
}

// text label of hub size on top surface

module toplabel() {
    fontspc = 0.8*topfontsize;
    size_label = str(round(hub_dia), "×", round(inner_width));
    charangle = 2*atan(0.5*fontspc / ihubr);
    labelr = 0.5*(ihubr+ohubr);//bearingr+bearing_chamfer+0.5;
    labelarc = charangle * (len(size_label) - 1);
    for(n=[0:len(size_label)-1])
        let(a=0.5*labelarc-n*charangle)
            rotate([0,0,a]) translate([labelr, 0, halfspoolwid-1])
                rotate([0,0,-90])// rotate([0,180,0])
                    linear_extrude(2, convexity=6) text(size_label[n], size=topfontsize, font=labelfont, halign="center", valign="center");
}

// text label of hub size on side

module sidelabel() {
    circle_label(label, halfspoolwid-1.5*sidefontsize);
    size_label = str(round(hub_dia), "×", round(inner_width));
    circle_label(size_label, halfspoolwid-3*sidefontsize);
}

module circle_label(txt, baseheight) {
    fontspc = 0.82*sidefontsize;
    charangle = 1.1*2*asin(0.5*fontspc / ohubr);
    labelarc = charangle * (len(txt) - 1);
    canvasarc = slotarc + xholearc + 2*ehole_side_clearance_angle;
    castart = -0.5*slotarc-ehole_side_clearance_angle;
    midcanvas = castart + 0.5*canvasarc;
    labelstart = midcanvas - labelarc/2;
    for(n=[0:len(txt)-1])
        let(a=labelstart+n*charangle)
            rotate([0,0,a]) translate([ohubr-0.6, 0, baseheight])
                rotate([90,0,90])
                    linear_extrude(2, convexity=6) text(txt[n], size=sidefontsize, font=labelfont, halign="center", valign="baseline");
}

// straight horizontal hole, intended for penetration in hub

module straight_hole(rhole, length, center=false) {
    translate([center ? -0.5*length : 0, 0, 0])
        rotate([90,0,0]) rotate([0,90,0])
            linear_extrude(length) horizontal_hole_profile(r=rhole);
}

// curved hole, intended for just inside of spool rim

module curved_hole(rhole, rmax, arc, fn=144) {
    rotate([0,0,-0.5*arc]) rotate_extrude(angle=arc, convexity=4, $fn=fn)
        translate([rmax-rhole,0,0])
            horizontal_hole_profile(r=rhole);
}

// horizontal hole profile
// This creates a hole that should not be intruded by layer bridging or layer edge rounding at the top and bottom, accounting for the allowable overhang angle. As an example, at 3mm in diameter with 0.30mm layer height, this profile prints as a round hole using (or at least fits a round rod).

module horizontal_hole_profile(d=3, r=0, ang=40, layerht=0.3) {
    dia = d > 0 ? d : 2*r;
    rd = r > 0 ? r : d/2;
    bottom_tan_angle = acos(rd/(rd+layerht));
    xb = rd*sin(bottom_tan_angle);
    yb = rd*cos(bottom_tan_angle);
    xt = rd*sin(ang);
    yt = rd*cos(ang);
    m = -tan(ang); // slope in line y = m*x + b
    b = yt - m * xt;
    d = (rd+layerht-b) / m;
    polygon(points = [
        [-d, rd+layerht], [d, rd+layerht], [xt, yt],
        for(a = [90-ang:-5:-90+bottom_tan_angle]) [rd*cos(a), rd*sin(a)],
        [xb, -yb], [0, -rd-layerht], [-xb, -yb],
        for(a = [265-bottom_tan_angle:-5:90+ang]) [rd*cos(a), rd*sin(a)]
    ]);
}

// ========== functions ==========

// ---------- Bezier cubic curve ----------

// get an x,y coordinate of a cubic Bezier curve given 4 x,y control points given in the array p[][]
function bezier_point2d(t, p) = [ // t=0...1, p=array of 4 [x,y] control points
    bezier_coordinate(t, p[0][0],p[1][0],p[2][0],p[3][0]),
    bezier_coordinate(t, p[0][1],p[1][1],p[2][1],p[3][1])
];

// return coordinate of Bezier curve at location t in the interval 0...1
// called twice by bezier_point2d(), once to pass x-coordinate coefficients and again to pass y-coordinate coefficients
function bezier_coordinate(t, n0, n1, n2, n3) =
    n0*pow((1-t), 3) + 3*n1*t*pow((1-t), 2) + 3*n2*pow(t, 2) * (1-t) + n3*pow(t, 3);
