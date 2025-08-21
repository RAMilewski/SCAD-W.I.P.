include<BOSL2/std.scad>


function octa_sphere(r) =
    let(
        subdivs = quantup(segs(r),4)/4,
        pts = [
            for (p = [0:1:subdivs])
            let(
                phi = p * 90/subdivs,
                row = [
                    for (t = [0:1:p])
                    let(theta = t * 90/(p?p:1))
                    spherical_to_xyz(r, theta, phi)
                ],
                vec = p? last(row) - row[0] : BACK,
                rot_row = rot(a=-90+phi, v=vec, cp=row[0], p=row),
                row_out = [for (pt = rot_row) let(sph = xyz_to_spherical(pt)) spherical_to_xyz(r,sph[1],sph[2])]
            ) row_out
        ],
        octant_vnf = vnf_tri_array(pts),
        top_vnf = vnf_join([
            for (a=[0:90:359])
            zrot(a, p=octant_vnf)
        ]),
        bot_vnf = zflip(p=top_vnf),
        full_vnf = vnf_join([top_vnf, bot_vnf])
    ) full_vnf;

vnf_polyhedron(octa_sphere(100, $fn=8));

