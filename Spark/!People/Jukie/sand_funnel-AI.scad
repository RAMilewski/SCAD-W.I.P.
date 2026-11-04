include <BOSL2/std.scad>

$fn = 144;

// --- Tube ---
tube_od  = 23;       // outer diameter
tube_h   = 50;       // height

// --- Internal hourglass bore ---
throat_d = 25.4/8;   // 3.175mm - narrow waist, at mid height
funnel_d = 20;       // cone mouth diameter at each end

// --- Flange ---
flange   = 15;       // how far it sticks out past the tube's OD
flange_t_in  = 2.0;  // thickness where it meets the tube
flange_t_out = 0.8;  // thickness at the outer edge

flange_r_out = tube_od/2 + flange;
flange_r_in  = tube_od/2 - 0.5;   // buried in the wall, so it welds cleanly

diff()
cyl(h=tube_h, d=tube_od, anchor=CENTER) {
    // Two cones hollowed out, narrow ends meeting in the middle
    tag("remove") zflip_copy()
        cyl(h=tube_h/2, d1=throat_d, d2=funnel_d, anchor=BOT);

    // Tapered flange at the vertical centre
    rotate_extrude(angle=360)
        polygon([
            [flange_r_in,  -flange_t_in/2],
            [flange_r_out, -flange_t_out/2],
            [flange_r_out,  flange_t_out/2],
            [flange_r_in,   flange_t_in/2]
        ]);
}
+