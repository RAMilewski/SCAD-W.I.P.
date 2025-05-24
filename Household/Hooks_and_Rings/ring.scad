include <BOSL2/std.scad>

// Module: connector_ring()
// Synopsis: Build a part combining a y-cylinder with a prismoid, generally used to anchor the cylinder to a flat surface
// SynTags: Geom
// Topics: 
// See Also: 
// Usage:
//   connector_ring(base_w, base_h, d_rad, thickness, [holeR=], [holeD_Bool=], [rounding=], [roundingb=], [roundingh=], [anchor=], [spin=], [orient=])
// Description:
//   Combines a prismoid polyhedron (front and back faces parallel, top face centered over bottom face)
//   with the upper portion of a Y-cylinder to form an attachable ring.  Optionally a circular or semicircular
//   hole, sharing the same center of rotation as the larger Y-cylinder. Three rounding variables are used
//   to customize the part.  Base rounding will typically be negative, to attach to a flat surface.  The
//   edge rounding and hole rounding should be positive.
//   .
//   Some constraints to be aware of:
// Arguments:
//   base_w = base width, x-dimension of the flat bottom surface
//   base_h = base height, z-dimension from the base to the center of the Y-cylinder
//   d_rad = radius of the Y-cylinder
//   thickness = y-dimension of the part
//   ---
//   holeR = optional radius of the center hole
//   holeD_Bool = Boolean, set true to make the center hole to be semicircular.  False makes the hole to be circular.
//   rounding = rounding of the vertical-ish edges of the prismoid and the exposed edges of the Y-cylinder
//   roundingb = base rounding, typically negative value
//   roundingh = rounding of the hole
//   anchor = Translate so anchor point is at origin (0,0,0).  See [anchor](attachments.scad#subsection-anchor).  Default: `CENTER`
//   spin = Rotate this many degrees around the Z axis.  See [spin](attachments.scad#subsection-spin).  Default: `0`
//   orient = Vector to rotate top towards.  See [orient](attachments.scad#subsection-orient).  Default: `UP`
// Named anchors:
//   hole_ctr_front = front, center of the Y-cylinder (same as the part FRONT+CENTER if base_h=d_rad)
//   hole_ctr_back = back, center of the Y-cylinder (same as the part BACK+CENTER if base_h=d_rad)
//   tangent_right = right side anchor at the point where the prismoid merges with Y-cylinder, at y=0
//   tangent_left = left side anchor at the point where the prismoid merges with Y-cylinder, at y=0
// Example: Basic usage
//   connector_ring(50, 25, 25, 10);
// Example: Widen the base, add base rounding
//   connector_ring(60, 25, 25, 10, roundingb=-3);
// Example: Narrow base.  The corners of the base must be outside the Y-cylinder in order to calculate a tangent between the prismoid and cylinder.
//   connector_ring(40, 20, 25, 10);
//   up(20) color("blue", 0.25) ycyl(r=25, h=11);
//   right(20) color("red") ycyl(r=1, h=11);
// Example: Add a through-hole with rounding on the hole edge
//   connector_ring(50, 40, 25, 10, holeR=20);
// Example: base_h must be greater than 0;
//   connector_ring(50, 0.1, 25, 10);
// Example: When using rounding with holeR>0, base_h must be greater than holeR + roundingh (+abs(roundingb) if roundingb < 0)
//   connector_ring(50, 26.1, 25, 10, holeR=20, roundingh=3, roundingb=-3);
// Example: Rounding all edges
//   connector_ring(50, 40, 25, 10, holeR=15, rounding=5, roundingh=5, roundingb=-5);
// Example: Semi-circular through hole with holeD_Bool = true
//   connector_ring(50, 12, 25, 10, holeR=15, holeD_Bool=true, rounding=5, roundingh=5, roundingb=-5);
// Example: The connector_ring includes 4 custom anchors in addition to the standard set: front & back at the center of the Y-cylinder component and left & right at the tangent points.
//   connector_ring(50, 25, 25, 10) show_anchors();
// Example: Use the custom anchor to place a screw hole
//    include <BOSL2/screws.scad>
//    connector_ring(20, 15, 7, 10, roundingb=-3) 
//       attach("hole_ctr_front") 
//         #screw_hole("M5", length=20, head="socket", atype="head", anchor=TOP, orient=UP);


module connector_ring(base_w, base_h, d_rad, thickness, holeR=0, holeD_Bool=false,
            rounding=0, roundingb=0, roundingh=0,
            anchor=BOTTOM, spin=0, orient=UP) {

    assert(sqrt((0.5*base_w)^2 + base_h^2)>d_rad, 
        "Point [0.5*base_w, 0] must be outside the circle of radius d_rad centered at [0, base_h]");
    max_holeR = holeR > 0 && roundingb < 0 ? base_h + roundingb
                                : base_h;
    if (holeR > 0 && !holeD_Bool) assert(holeR + roundingh < max_holeR, 
                "holeR + roundingh must be less than max_holeR");
    assert(roundingh >= 0, "roundingh must be greater than or equal to 0");
    assert(d_rad > holeR, "Part radius must be larger than the through hole");
    // I cannot imagine anyone would ever want rounding 
    //      to be < 0, but allowed for now

    z_offset = 0.5*(base_h - d_rad);
    tangents = circle_point_tangents(r=d_rad, cp=[0, base_h], 
                pt=[0.5*base_w, 0]);
    // we want the tangent with the larger y value
    tangent = tangents[0].y > tangents[1].y
            ? tangents[0] : tangents[1];
    // anchor calcs
    angle = atan((tangent.x - 0.5*base_w)/tangent.y);
    top_x = 0.5*base_w + (base_h + d_rad)*tan(angle);
    // when d_rad > 0.5*base_w, need to move the anchor
    // use x^2 + y^2 = r^2, x = sqrt(r^2 - y^2)
    delta_y = z_offset;
    mid_x = sqrt(d_rad^2 - delta_y^2);

    anchors = [
        named_anchor("hole_ctr_front", [0, -thickness/2, z_offset], FRONT, 0),
        named_anchor("hole_ctr_back", [0, thickness/2, z_offset], BACK, 0),
        named_anchor("tangent_right", [tangent[0], 0, tangent[1] - base_h + z_offset], RIGHT, 0),
        named_anchor("tangent_left", [-tangent[0], 0, tangent[1] - base_h + z_offset], LEFT, 0),
    ];
    override = [
        for (i = [-1, 1], j=[-1:1], k=[0:1])
            if (k==0 && j!=0 && d_rad > 0.5*base_w)
                [[i, j, 0], 
                [mid_x*unit([i, 0, 0]) + 0.5*thickness*unit([0, j, 0])]]
            else if (k==0 && d_rad > 0.5*base_w) 
                [[i, 0, 0], [mid_x*unit([i, 0, 0])]]
            else if (k==1 && j==0) 
                [[i, 0, 1], [d_rad*sin(45)*unit([i, 0, 0]) 
                            + (z_offset + d_rad*sin(45))*unit([0, 0, k])]]
            else if (k==1)
                [[i, j, 1], [d_rad*sin(45)*unit([i, 0, 0]) 
                                + 0.5*thickness*unit([0, j, 0])
                                + (z_offset + d_rad*sin(45))*unit([0, 0, k])]]
    ];

    attachable(anchor, spin, orient, 
                size=[base_w, thickness, base_h + d_rad],
                size2=[2*top_x, thickness],
                anchors=anchors, override=override) {
        up(z_offset) difference() {
            union() {
                top_half(s=2.1*max(base_w, 2*d_rad, thickness), 
                            z=tangent.y - base_h)
                    ycyl(r=d_rad, h=thickness, rounding=rounding);
                up(tangent.y - base_h)
                    rounded_prism(rect([base_w, thickness]), 
                        rect([2*tangent.x, thickness]), h=tangent.y, 
                        joint_bot=roundingb, joint_sides=rounding, 
                        k_sides=0.92, k_bot=0.92, anchor=TOP);
            }
            if (holeR > 0) {
                top_half(s=2.1*max(2*holeR, thickness), 
                            z = holeD_Bool ? 0 : -holeR - roundingh - 1)
                    ycyl(r=holeR, h=thickness + 0.01, 
                            rounding=-roundingh);
                if(roundingh > 0 && holeD_Bool) {
                    rpath = path_merge_collinear( concat(
                        path2d(arc(cp=[holeR, 0], r=roundingh, start=0, angle=-90)),
                        [[holeR, -roundingh], [-holeR, -roundingh], ],
                        path2d(arc(cp=[-holeR, 0], r=roundingh, start=270, angle=-90)),
                    ));
                    for (m = [0, 1]) mirror([0, m, 0])
                        back(0.5*thickness) xrot(90) 
                        path_sweep(
                            mask2d_roundover(r=roundingh, 
                                    anchor=RIGHT), rpath);
                }
            }   // holeR
        } // difference
        children();
    } // attachable
}

 connector_ring(50, 26.1, 25, 10, holeR=20, roundingh=3, roundingb=-3);