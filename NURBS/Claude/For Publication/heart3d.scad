include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

data = [[0,10], [25,20], [30,0], [20,-15], [0,-30], [-20,-15], [-30,0], [-25,20]];
depth = function(x) 0.5 + sin(180 * x / 31) * 6;
heart_shape_2d = nurbs_curve(nurbs_interp(data, 3, closed = true,  
        deriv = [NAN,polar_to_xy(1.1,-40),undef,undef,NAN,undef,undef,polar_to_xy(1.1,40)],
        curvature = [undef,-0.06,undef,undef,undef,undef,undef,-0.06]));
points = [
    for (i = [-31:2:31]) 
        flatten(polygon_line_intersection(heart_shape_2d,[[i,25],[i,-30]])), 
];
span = [
    for (i = [0:len(points)-1]) 
        abs(points[i][1].y-points[i][0].y),
];
samples = 11; 
surface = [
    repeat([-31.1,7,0], samples),
    for (i = [0:len(points)-1]) 
       move(points[i][0]-[0,span[i]/2], yrot(90, path3d(resample_path(ellipse([depth(i),span[i]/2]),samples),0))),
    repeat([31.1,7,0], samples),
];
xrot(90)
nurbs_interp_surface(surface,3, method = "foley", col_wrap = true, splinesteps = 3, extra_pts = 5, smooth = 1, normal1 = RIGHT/2, normal2 = LEFT/2);
