include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

data = [[0,10], [25,20], [30,0], [20,-15], [0,-30], [-20,-15], [-30,0], [-25,20]];

depth = function(x) sin(180 * x / 31);

result = nurbs_interp(data, 3, closed = true,  
        deriv = [NAN,polar_to_xy(1.1,-40),undef,undef,NAN,undef,undef,polar_to_xy(1.1,40)],
        curvature = [undef,-0.06,undef,undef,undef,undef,undef,-0.06]);

shape = nurbs_curve(result);



points = [
    for (i = [-29:2:29]) 
        flatten(polygon_line_intersection(shape,[[i,25],[i,-30]])), 
];

span = [
    for (i = [0:len(points)-1]) 
        abs(points[i][1].y-points[i][0].y),
];

samples = 30;
data3 = [
    repeat([-32,7,0], samples),
    for (i = [0:len(points)-1]) 
       move(points[i][0]-[0,span[i]/2], yrot(90, path3d(resample_path(ellipse([6*depth(i)+4,span[i]/2]),samples),0))),
    repeat([32,7,0], samples),
];

nurbs_interp_surface(data3,3, col_wrap = true, splinesteps = 6, normal1 = RIGHT*2, normal2 = LEFT*2);

for (i=[0:31]) echo(depth(i));



/*

    for (i = [-29:2:29]) {
        path = ([[i,25],[i,-30]]);
        stroke(path);
    }

/* */