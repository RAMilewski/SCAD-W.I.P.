include<BOSL2/std.scad>

batt = [20,24,16,11];
n = len(batt);
stroke(circle(30));
for (i = [0:len(batt)-1]) {
    zrot(360/n * i) move([30 - batt[i]/4,0]) cyl(h = 5, d = batt[i]);
}











/*
cyl(h=4, d = 24, $fn = 6, chamfer = 2, anchor = BOT);
zrot_copies(n = 3, sa = 10) #cuboid([2,25,5], anchor = BOT);



r = 40;  // size of the base
theta = 70; // intermediate control point angle from Z axis
d = r*.8;
bz = 15; // control point z to raise the curve to z >= 0;

layer_bez = flatten([
    bez_begin ([-r,0,bz],  90, d, p=theta),
    bez_tang  ([0,r,bz],    0, d, p=theta),
    bez_tang  ([r,0,bz],  -90, d, p=theta),
    bez_tang  ([0,-r,bz], 180, d, p=theta),    
    bez_end   ([-r,0,bz], -90, d, p=180 - theta)
]);

debug_bezier(layer_bez);
debug_bezier(path2d(layer_bez));
*/