 include <BOSL2/std.scad>
 include <texture.scad>


base_d = 30;
top_d = 45;
h =  40;
wall = 2;
tx_reps_x = 6;
tx_depth = 0.5;   // [-1:0.25:1]
td_ang = 35;    // teardrop angle
vm = true;     // render for vase_mode
ribs = false;   // add ribs to indside bottom
ruler = false;  // show ruler
x_ray = false;  // show half view

/* [Hidden] */

$fn = 72;
base_od = base_d + 2*wall;
top_od = top_d + 2*wall;

if (x_ray) { back_half(s=top_d * 2) cup(); } 
else cup();




module cup() { 
    diff() {
        cyl(h = h, d1 = base_od, d2 = top_od, rounding1 = 4*wall, teardrop = td_ang, 
            texture = texture, tex_depth = tx_depth, tex_reps = [tx_reps_x,1], anchor = BOT)
            if(!vm) position(TOP) torus(d_min = wall*1.75, d_maj = top_d + wall/2 + tx_depth * 2);

        if (!vm) up(2*wall) {
            tag("remove") cyl(h = h, d1 = base_d, d2 = top_d, rounding1 = 2, anchor = BOT);
            if (ribs) tag("keep") zrot_copies(n = 6, d = base_d/5) xcyl(d = wall, h = base_d/3, rounding = wall/2, anchor = LEFT);
        }
        if ($preview && ruler) up(h+wall) tag("keep") ruler();
    }
}



