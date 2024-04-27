 include <BOSL2/std.scad>
 include <texture.scad>

$fn = 72;

base_dia = 35;
mid_dia = 50;
wall = 2;
h =  50;
margin = 5;

idia = base_dia + 2 * margin;
idia2 = idia * 1.15;
odia = idia + 2 * wall;
odia2 = idia2 + 2 * wall;

test();

module dish1() {  //straight sides
    cyl(d1 = idia, d2 = odia, h = wall, anchor = BOT) {
        zrot_copies(n = 6, d = idia/5) position(TOP) xcyl(d = wall, h = idia/3, rounding = wall/2, anchor = LEFT) ;
        position(BOT) tube(id1 = idia, od1 = odia, id2 = idia2, od2 = odia2, h = h, anchor = BOT)
            position(TOP) torus(d_min = wall, d_maj = odia2 - wall);
    }
}

module dish2() { //teardrop rounded sides
    diff() {
        cyl(h = h, d = mid_dia + 2 * wall, rounding1 = 15, teardrop = 35, anchor = BOT);
        up(2*wall) {
            tag("remove") cyl(h = h, d1 = base_dia + 4  * wall, d2 = mid_dia, rounding1 = 6, anchor = BOT);
            tag("keep") zrot_copies(n = 6, d = idia/5) xcyl(d = wall*2, h = idia/3, rounding = wall/2, anchor = LEFT, $fn = 6);
        }
        if ($preview) up(h) tag("keep") ruler();
    }
}


module dish3() { //teardrop rounded sides - textured
    diff() {
        cyl(h = h, d = mid_dia + 2 * wall, rounding1 = 12, teardrop = 35, 
            texture = texture, tex_depth = 0.5, tex_reps = [4,1], anchor = BOT);
        up(2*wall) {
            tag("remove") cyl(h = h, d1 = base_dia + 4  * wall, d2 = mid_dia, rounding1 = 6, anchor = BOT);
            tag("keep") zrot_copies(n = 6, d = idia/5) xcyl(d = wall*2, h = idia/3, rounding = wall/2, anchor = LEFT);
        }
        //if ($preview) up(h) tag("keep") ruler();
    }
}


module test() { //textured cylinder
   // diff() {
        cyl(h =40, d1 = 35, d2=48, rounding1 = 12, teardrop = 35, 
            texture = texture, tex_depth = 0.5, tex_reps = [8,1], anchor = BOT);
}


