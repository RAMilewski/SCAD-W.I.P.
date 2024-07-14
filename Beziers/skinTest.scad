include<BOSL2/std.scad>
include<BOSL2/beziers.scad>


height = 20;

r = 40;
ratio = r/50;
cp = 27.625 * ratio;


bez = flatten([
    bez_begin([-r,0],  90, cp),
    bez_tang ([0,r],    0, cp),
    bez_tang ([r,0],  -90, cp),
    bez_tang ([0,-r], 180, cp),
    bez_end  ([-r,0], -90, cp)
]);

base = path3d(bezpath_curve(bez));

bez2 = flatten([
     bez_begin([-50,0,20],  BACK, 27.625),
    bez_joint([0,50,30],  LEFT+UP, RIGHT+UP, 27.625,27.625),
    bez_tang ([50,0,20],   FWD, 27.625),
    bez_joint([0,-50,30], RIGHT+DOWN, LEFT+DOWN, 27.625,27.625),
    bez_end  ([-50,0,20],  FWD, 27.625)
]);

top = bezpath_curve(bez2);
top2 = scale([.95,.95,1],top);
top_n = len(top);


floor = up(2,path3d(regular_ngon(n=top_n*4, r = r-2)));

echo(len(top));

left_half() 
skin([base, base, top, top2, floor], slices=0, refine=1, method="reindex");