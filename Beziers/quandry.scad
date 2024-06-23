include<BOSL2/std.scad>
$fn = 144;

r1 = 10;
r2 = 6;
h = 38;

u1 = 10;
u2 = 25;

eps = 0.001;

echo(ru(u1), ru(u2));
echo((r2 - r1)/h, (r2 - r1)/h * h);


hyp = adj_opp_to_hyp(ru(u1)-ru(u2),(u2-u1) );
echo(hyp);

cyl(r1 = r1, r2 = r2, h = h, anchor = BOT);

up(u1) color("red") cyl(r1 = ru(u1), r2 = ru(u2), h = u2 - u1, anchor = BOT);


function ru(u) = r1 + (r2 - r1)/h * u;

