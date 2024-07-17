include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

wall = -2;
wallScale = [0.95,0.95,1];
steps = 16; 
sidebez = [[15,0], [40,40], [-20,50], [20,80]];
sidebase = sidebez[0].x;
h = sidebez[len(sidebez)-1].y;
step = h/steps;

toppath = flatten([
    bez_begin([-50,0,20],  BACK, 10),
    bez_joint([0,50,20],  LEFT+UP, RIGHT+UP, 20,20),
    bez_tang ([50,0,20],   FWD, 20),
    bez_joint([0,-50,30], RIGHT+DOWN, LEFT+DOWN, 20,20),
    bez_end  ([-50,0,20],  FWD, 10)
]);

echo(sidebez[0].x);

function scalefactor(z) =
    let(x_base = sidebez[0].x)
    let (u = bezier_line_intersection(sidebez, [[0, z * step],[1, z * step]]))
    flatten(bezier_points(sidebez,u)).x/x_base;

// function path_xy_offset() = 

echo(scalefactor(3));


/*







top = bezpath_curve(toppath);
base = path3d(path2d(top));
top2 = scale(wallScale, top);

temp = offset(path2d(base), delta = wall, closed = true);
floor = up(2,path3d(offset(path2d(base), delta = wall, closed = true)));

//left_half() 
skin([base, top, top2, floor], slices=0, refine=1, method="reindex");

/* */