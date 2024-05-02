 include <BOSL2/std.scad>
 include <texture.data>
 include <blank.data>

/* [Size] */
base_d =40;
top_d = 50;
h =  40;
wall = 2;

/* [Texture] */
textured = true;
tx_reps = 3;
tx_depth = 0.5; // [-1:0.25:1]

/* [Options] */
td_ang = 35;    // [35:60] 
td_rad = 4;     // roudning radius
vase = true;    // render for vase_mode
ribs = false;   // add ribs to indside bottom
ruler = false;  // show ruler
x_ray = false;  // show half view

/* [Hidden] */
$fn = 72;
base_od = base_d + 2*wall;
top_od = top_d + 2*wall;



// Main
if (x_ray) { back_half(s=top_d * 2) cup(); } 
else cup();


// Modules
module cup() {
    texture = textured ? texture : blank;
    diff() {
        cyl(h = h, d1 = base_od, d2 = top_od, rounding1 = td_rad, anchor = BOT,
            teardrop = 45, texture = texture, tex_depth = tx_depth, tex_reps = [tx_reps,1])
                if(!vase) position(TOP) torus(d_min = wall*1.75, d_maj = top_d + wall/2 + tx_depth *2);

        if (!vase) up(2*wall) {
            tag("remove") cyl(h = h, d1 = base_d, d2 = top_d, rounding1 = 2, anchor = BOT);
            if (ribs) tag("keep") zrot_copies(n = 6, d = base_d/5) xcyl(d = wall, h = base_d/3, rounding = wall/2, anchor = LEFT);
        }
        if ($preview && ruler) up(h+wall) tag("keep") ruler();
    }
}



