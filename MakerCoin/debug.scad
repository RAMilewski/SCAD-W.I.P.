include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

r1 = 25;    // Major radius 
r2 = 5;     // radius of the edge
edgefit = 9.5;

edgebez = flatten([
        bez_begin(cylindrical_to_xyz(r1+r2-edgefit,0,r2),FWD,4),
        bez_tang (cylindrical_to_xyz(r1,-14.5,0),DOWN,4.1),
        bez_tang (cylindrical_to_xyz(r1+r2-edgefit,0,-r2),BACK,4),
        bez_tang (cylindrical_to_xyz(r1,14.5,0),UP,4.1),
        bez_end  (cylindrical_to_xyz(r1+r2-edgefit,0,r2),BACK,4)
]);

edge = bezpath_curve(edgebez);
//stroke(edge, closed = true);

debug_bezier(edgebez, width = 0.2);
move_copies(bezier_curve(edgebez, 3)) sphere(.2);

