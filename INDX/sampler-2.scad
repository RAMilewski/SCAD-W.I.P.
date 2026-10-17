include <BOSL2/std.scad>

$export_name = "sampler-2";

$fn = 72;

cone_size = 10;

size      = 5*cone_size;
slab_h    = 2;

slab_color   = "#d1d2da";
corner_color = "red";
face_color   = "blue";
inner_color  = "green";


// Every cone that touches the perimeter is tangent to it, which means its
// center sits exactly cone_size/2 inside the edge. On a square that single
// inset serves both families: backing a corner off along its 45 degree
// bisector by (cone_size/2)/sin(45) moves it cone_size/2 in each axis, so the
// corner centers and the face centers all lie on the same inset square.
inset = size/2 - cone_size/2;

// One cone at each corner of that inset square.
corners = inset * [[1, 1], [-1, 1], [-1, -1], [1, -1]];

// One cone centered on each of the four faces.
face_pts = inset * [[1, 0], [0, 1], [-1, 0], [0, -1]];

// One cone on each diagonal, halfway from the center out to the corner cone.
inner_pts = [for (c = corners) c/2];


color_this(slab_color)
    cuboid([size, size,slab_h], rounding = 5, edges = "Z", $fn = 72)

position(TOP) {
    move_copies(corners)   color_cone(corner_color);
    move_copies(face_pts)  color_cone(face_color);
    move_copies(inner_pts) color_cone(inner_color);
}


module color_cone(c = "orange") {
        color(c) cyl(d1 = cone_size, d2 = 0, h = cone_size, anchor = BOT);
}
