include <BOSL2/std.scad>

// module post_lock()

// Makes a tile with a staggered pattern of knobs which interlock with a similar object.

// Arguments:
// tile - the size of the tile as a 3-vector  Default = [25,25,0.5]
// border - the size of the blank border around the edge of the tile. Default = 3
// tab - a boolean that controls whether or not there is a semicircular tab on one edge of the tile.  Default = true

// h = The height of the post base. Default = 0.6
// d1 = The diameter of the post base. Default = 1
// d2 = The diameter of the inverted onion atop the base. Default = 1.5
// ang = The angle of the pointy end of the onion. Default = 20˚
// spacing = The spacing between posts as a multiple of d2. Default = 0.9

$fn = 64;


post_lock(h = 1, d1 = 2, d2 = 3, spacing = 0.75, tab = true); 

//post_lock(spacing = 0.9, tab = true);


module post_lock(tile = [25,25,0.5], border = [3,3], tab = false,
        spacing = 0.9, h = 0.6, d1 = 1, d2 = 1.5, ang = 20, $fn = 8) {

    interval = spacing * d2;
    field = tile - 2 * border;
    count = v_floor(field/interval);
  
    cuboid(tile) {
        if (tab) position(RIGHT) cyl(h = tile.z, d = tile.y, $fn = 64);
        position(TOP) grid_copies(size = field, n = count, stagger = true) 
            cyl(h = h, d = d1, rounding1 = -.3 * d1, anchor = BOT)
                attach(TOP,TOP) onion(d = d2, ang = ang, cap_h = d2/2 + h, realign = true);
    }
}