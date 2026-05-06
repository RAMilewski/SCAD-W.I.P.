include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

data = [[0,10], [25,20], [30,0], [20,-15], [0,-30], [-20,-15], [-30,0], [-25,20], [0,10]];

left(50){

    debug_nurbs_interp(data, 3, closed = false, method = "centripetal", corners=[4]);

    path1 = nurbs_curve(nurbs_interp(data, 3, closed = false, method = "centripetal", 
        deriv = [undef,undef,undef,undef,NAN,undef,undef,undef,undef]));
    fwd(75) stroke(path1, closed = true);
}

right(50){

    debug_nurbs_interp(slice(data,0,-2), 3, closed = true, method = "centripetal", 
        deriv = [NAN,[1,-1]*0.8,undef,undef,NAN,undef,undef,[1,1]*0.8],
        curvature = [undef,-0.06,undef,undef,undef,undef,undef,-0.06]);

    path2 = nurbs_curve(nurbs_interp(slice(data,0,-2), 3, closed = true, method = "centripetal", 
        deriv = [NAN,[1,-1]*0.8,undef,undef,NAN,undef,undef,[1,1]*0.8],
        curvature = [undef,-0.06,undef,undef,undef,undef,undef,-0.06]));
    fwd(75) stroke(path2, closed = true);
}

right(150) {

    debug_nurbs_interp(slice(data,0,-2), 3, closed = true, method = "centripetal", 
        deriv = [NAN,polar_to_xy(1.1,-40),undef,undef,NAN,undef,undef,polar_to_xy(1.1,40)],
        curvature = [undef,-0.06,undef,undef,undef,undef,undef,-0.06], show_knots = true);

    path3 = nurbs_curve(nurbs_interp(slice(data,0,-2), 3, closed = true, method = "centripetal", 
        deriv = [NAN,polar_to_xy(1.1,-40),undef,undef,NAN,undef,undef,polar_to_xy(1.1,40)],
        curvature = [undef,-0.06,undef,undef,undef,undef,undef,-0.06]));
    fwd(75) stroke(path3, closed = true);


}


right(250) {

    debug_nurbs_interp(slice(data,0,-2), 3, closed = true, method = "centripetal", extra_pts=0,
        deriv = [NAN,[1,-.8]*0.7,undef,undef,NAN,undef,undef,[1,.8]*0.7]);

    path4 = nurbs_curve(nurbs_interp(slice(data,0,-2), 3, closed = true, method = "centripetal", extra_pts=0,
        deriv = [NAN,[1,-.8]*0.7,undef,undef,NAN,undef,undef,[1,.8]*0.7]));
    fwd(75) stroke(path4, closed = true);

}