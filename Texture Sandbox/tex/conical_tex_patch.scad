include<BOSL2/std.scad>
$fn = 144;

r1 = 10;
r2 = 6;
h = 38;

u1 = 20;
u2 = 30;

function ru(u) = r1 + (r2 - r1)/h * u;

adj = u2 - u1;
opp = ru(u1)-ru(u2);
hyp = adj_opp_to_hyp(adj,opp);
theta = hyp_adj_to_ang(hyp,adj);

region = right(ru(u1),rect([0.001, hyp], spin = theta));

diff() {
    cyl(r1 = r1, r2 = r2, h = h, anchor = BOT);
    tex = texture("dots", $fn = 16);
    tag("keep") up(u1) 
    rotate_sweep(region,360,texture = tex, tex_reps = [12,4], tex_depth = 0.5);
}


/*  OpenSCAD 2024.06.16 (MacOS)

    TEXTURE                 MANIFOLD    CGAL

    bricks                  OK          F6 Fails
    bricks_vnf  †1          OK          F6 Fails      
    checkers    †2          OK          OK
    cones                   OK          F6 Fails
    cubes       †2          OK          OK
    diamonds    †4          OK          OK
    diamonds_vnf            OK          OK
    dimples                 F6 Fails    F6 Fails
    dots                    F6 Fails    OK †3 
    hex_grid                OK          OK
    hills                   OK †3       OK
    pyramids                OK          OK
    pyramids_vnf            OK          OK
    ribs                    OK          OK
    rough                   OK †3       OK
    tri_grid                OK          OK 
    trunc_diamonds          OK †3       OK
    trunc_pyramids          OK          OK
    trunc_pyramids_vnf      OK          OK
    trunc_ribs              OK          OK
    trunc_ribs_vnf          OK          OK
    wave_ribs               OK          OK

    Notes

        1   Bevels top row of texture w/gap <0.14
        2   Bevels top row of texture
        3   Works but with NotManifold or Mesh Not Closed warning.
        4   Top and bottom row different.



/* */

