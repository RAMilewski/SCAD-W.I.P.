include <BOSL2/std.scad>

$export_name = "sampler-1";

$fn = 72;

size      = 50;
cone_size = 10;
slab_h    = 1;

// Export splits objects by colour first, then by connected component. The cones
// are welded to the slab where they touch, so with no colours the whole model
// exports as ONE object. Distinct colours split it into 26: the slab, plus each
// cone separately (the cones touch only the slab, never each other).
//
// An enclosing color() overrides the inner ones, so the slab's colour must NOT
// wrap the cones -- which is why the cones sit outside the linear_sweep and are
// raised with up(slab_h) instead of attached with position(TOP).
slab_color   = "#9aa0a6";
corner_color = "#d94f4f";
edge_color   = "#4f8fd9";
inner_color  = "#4fd98f";


// Corner cones back off along the bisector by radius/sin(54). That makes each
// one tangent to both of its edges, so the corner centers already lie on the
// inset line the edge cones follow -- which is why interpolating between them
// keeps every cone tangent to the edge.
corner_r = size - cone_size/(2*cos(36));
corners  = regular_ngon(n = 5, or = corner_r);

// 3 cones per edge, evenly spaced between neighbouring corner cones.
edge_pts = [
    for (q = pair(corners, wrap = true))
        each lerp(q[0], q[1], [1,2,3]/4)
];

// One cone halfway from the center out to each corner cone.
inner_pts = [for (c = corners) c/2];


color(slab_color)
    linear_sweep(regular_ngon(n = 5, or = size, rounding = 5, $fn = 72), slab_h);

up(slab_h) {
    move_copies(corners)   color_cone(corner_color);
    move_copies(edge_pts)  color_cone(edge_color);
    move_copies(inner_pts) color_cone(inner_color);
}


module color_cone(c = "orange") {
        color(c) cyl(d1 = cone_size, d2 = 0, h = cone_size, anchor = BOT);
}
