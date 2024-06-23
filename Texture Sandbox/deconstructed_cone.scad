include<BOSL2/std.scad>
$fn = 144;

r1 = 10;
r2 = 6;
h = 38;

u1 = 20;
u2 = 25;

function r(u) = r1 + (r2 - r1)/h * u;

adj = u2 - u1;
opp = r(u1)-r(u2);
hyp = adj_opp_to_hyp(adj,opp);
theta = hyp_adj_to_ang(hyp,adj);

region = right(r(u1),rect([0.001, hyp], spin = theta));

diff() {
    *cyl(r1 = r1, r2 = r2, h = h, anchor = BOT);
    tag("keep") up(u1) 
    rotate_sweep(region,30,texture = "ribs", tex_reps = [1,2], tex_depth = 0.5);
}




