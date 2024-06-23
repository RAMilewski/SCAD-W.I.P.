include <BOSL2/std.scad>
include <BOSL2/beziers.scad>



$fs = .2;
$fa = 4;

difference () {
rotate ([45,0,0])
linear_extrude (height=15, twist=360, convexity=10) translate ([.1,-20]) square ([20,40]);
translate ([-50,-50,1]) cube (100);
}






/*
bez = [[20,0], [55,10], [-10,20], [20,30],  ];  
debug_bezier(bez);


line = [[0,5],[50,5]];
stroke(line);
u = bezier_line_intersection(bez,line);  
echo(u); //  [0.0435044]   

pt = bezier_points(bez,u);
echo(pt); //  [[24.0162, 5]]

/*

line2 = [[30,0],[10,80]];
stroke(line2);
u2 = bezier_line_intersection(bez,line2); 
echo(u2); //  [0.884305, 0.0946026, 0.555977]

pts = bezier_points(bez,u2);
echo(pts);; //  [[13.1003, 67.5989], [27.4135, 10.3461], [19.1568, 43.3726]]

/*

bez2 = bezpath_offset([15,0],bez);         


*/