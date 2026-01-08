
include<BOSL2/std.scad>

$fn = 120;

bw = 60;
bd = 100;

ds = 5;
dw = bw + 2*ds;
dd = bd + 20;
dh = 25;

sc = 0.5;

function DishShape2D() =
hull_region(concat(
yscale(sc, circle(d = dw)),
rect([dw, dd - sc*dw/2],anchor=FWD)
)
);

inside = offset(offset(DishShape2D(),-ds*2),r=ds);

difference() {
linear_sweep(DishShape2D(),height=dh);
offset_sweep(inside, height=dh, top=os_circle(r=-3),extra=1);
}