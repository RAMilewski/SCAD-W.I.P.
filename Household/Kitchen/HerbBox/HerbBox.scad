include <BOSL2/std.scad>
include <BOSL2/bottlecaps.scad>
include <TileDeco_500x100.scad>

$fn = 72;
// /* Box */
size = [220,100];
depth = 70;
wall = 4;
corner = 10;

// /* Spout */
od = 20;
id = 16;
extension = 60;
vent = 2;
cap_h = 26.5;
fillet = 3;
pot_dia = 80;

// /*Hidden*/
size2 = [size.x - 2.1 * wall, size.y - 2.1 * wall];

//left_half() 
//back_half()
spout();



module box() {
    cuboid([size.x,size.y,wall], rounding=corner, edges = "Z")
        position(TOP) rect_tube(size = size, l = depth, rounding = corner, wall = wall)
            position(FWD) xrot(90) textured_tile(size = [200,40,2], texture = TileDeco, tex_reps = [1,1], tex_depth = -2);
}

module spout() {
    //back_half(s= 200)
    diff() {
        pco1810_cap(texture = "ribbed", orient = DOWN, anchor = TOP) {
            tag("remove") position(BOT) up(3.1) cyl(d = id, h = cap_h, anchor = CENTER);
          
            position(BOT) cyl(d = od, h = 10, rounding2 = -fillet * 2, anchor = TOP)
                position(TOP) tube(od = od, id = id, h = extension, anchor = TOP);
                
        }
    }
}

module blank_lid(anchor=CENTER,spin=0,orient=UP) {
    attachable(anchor,spin,orient, size=[size.x,size.y,wall * 2]) {
        union() {
        cuboid([size.x,size.y,wall], rounding=corner, edges = "Z")
            position(TOP) rect_tube(size = size2, l = 5, rounding = corner, wall = wall);
        }
    children();
    }
}

module lid() {
    diff() {
        blank_lid(){
            position(TOP) down(wall/2) back(25) cyl(h = 3 * wall, d = od+8, rounding2 = wall, anchor = BOT)
                tag("remove") position(BOT) down(wall) cyl(h = wall * 5, d = od + .5, rounding1 = -corner, anchor = BOT);
            tag("remove") xcopies(n = 2, spacing = 120) cyl(h = wall + .1, d = pot_dia);
        }
    }
}