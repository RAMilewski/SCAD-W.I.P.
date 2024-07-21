include<BOSL2/std.scad>
include<BOSL2/beziers.scad>
include<BOSL2/rounding.scad>



sidebez = [[15,0], [40,40], [-20,50], [10,80]];
side = bezpath_curve(sidebez);
h = last(side).y;
sidebase = sidebez[0].x;
steps = len(side)-1;
step = h/steps;
size = 30;
wall = 2;
scale = 1-(2 * wall / size);
wallscale = [scale,scale,1];

echo(scale);

topbez = flatten([
    bez_begin([-size,0,0], BACK, 10),
    bez_joint([0,size,-3],  180,0, 5,5, 10,10),
    bez_tang ([size,0,0],  FWD, 20),
    bez_joint([0,-size,0], 0,180, 8,8, 120,120),
    bez_end  ([-size,0,0], FWD, 10)
]);

function layerscale(z) =
    let (u = bezier_line_intersection(sidebez, [[0, z * step],[1, z * step]]))
    flatten(bezier_points(sidebez,u)).x / sidebase;

top = bezpath_curve(topbez);
base = path3d(path2d(top));
floor = scale(wallscale, base);

rescaled = [for(i=[0:len(side)-1]) scale(layerscale(i),path3d(top))];

xyoffset = [for (curve = rescaled) hstack(offset(path2d(curve), delta = 12, same_length = true), column(curve,2))];

echo(xyoffset[0]);
echo("**********************");
echo(rescaled[0]);


for(i = [1:4:len(side)-1]) stroke(rescaled[i], width = 0.4, closed = true);
for(i = [1:4:len(side)-1]) color("blue") stroke(xyoffset[i], width = 0.4, closed = true);

/*

skin([ base, rescaled[2], rescaled[4] rescaled[6],
    rescaled2[6], rescaled[4], rescaled[2], floor], 
    z=[0,5,10,15,15,10,5,2], slices=0, refine=1, method="reindex");
/* */   