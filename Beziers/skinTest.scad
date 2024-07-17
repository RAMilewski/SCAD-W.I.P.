include<BOSL2/std.scad>
include<BOSL2/beziers.scad>


height = 20;
wall = 2;

r = 40;
ratio = r/50;
n = 4; //bezier segments to complete circle
cpf = 0.552285;
cpf2 = (4/3) * tan(180/(2*n));
cp = r * cpf;
echo(cpf, cpf2);

wallScale = [0.95,0.95,1];

basepath = flatten([
    bez_begin([-r,0],  90, cp),
    bez_tang ([0,r],    0, cp),
    bez_tang ([r,0],  -90, cp),
    bez_tang ([0,-r], 180, cp),
    bez_end  ([-r,0], -90, cp)
]);


toppath = flatten([
     bez_begin([-50,0,20],  BACK, 27.625),
    bez_joint([0,50,30],  LEFT+UP, RIGHT+UP, 27.625,27.625),
    bez_tang ([50,0,20],   FWD, 27.625),
    bez_joint([0,-50,30], RIGHT+DOWN, LEFT+DOWN, 27.625,27.625),
    bez_end  ([-50,0,20],  FWD, 27.625)
]);



base = path3d(bezpath_curve(basepath));
top = bezpath_curve(toppath);
top2 = offset(top, delta = wall, closed = true);
top_n = len(top);
floor = up(2,path3d(offset(base, delta = wall, closed = true)));


left_half() 
skin([base, top, top2, floor], slices=0, refine=1, method="reindex");