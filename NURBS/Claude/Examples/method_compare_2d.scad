include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//


type = "clamped"; // [closed,clamped]
count = 8;     // [4:1:25]
spread = 40;
degree = 3;  // [2,3,4]
methods = ["centripetal", "lockyer", "length", "dynamic", "foley"];
colors =  ["dodgerblue", "black", "gold", "pink","purple"];
test = "polygon"; // [polygon, random]

closed_stroke =  (type == "closed");
   

data = (test == "polygon") ? 
    random_polygon(count, spread/2)
:
    random_points(count,2,[spread/2,spread/2]);

/**/

// data = [[15.441, -1.50861], [0.513356, -16.4906], [-2.45483, -13.0896], [-4.45489, -9.67974], [-3.74439, 9.71124], [-1.66705, 10.9184], [8.09036, 12.2829], [15.7943, 10.4199]];
echo(data);

for (i = [0:4]) {
    plot(methods[i], colors[i], spread * i);
}

module plot(method, color, shift) {
    right(shift){
        path = nurbs_interp_curve(data, degree, splinesteps=32, method=method, type=type);
        color("red") move_copies(data) sphere(r=.5, $fn=16);
        color(color) {
            stroke(path, closed = closed_stroke, width=.2);
            fwd(25) text3d(method, size = 3, h = 0.1, anchor = CENTER);
        }
    }
}

fwd(35) right(spread*2.5) color("black")text3d(str("Degree = ",degree), size = 5, h = 0.1, anchor = CENTER);

path = smooth_path(data, splinesteps = 32);
right(spread*5){
    color("red") move_copies(data) sphere(r=.5, $fn=16);
    color("limegreen"){ 
        stroke(path, closed = closed_stroke, width=.2);
        fwd(25) text3d("smooth path", size = 3, h = 0.1, anchor = CENTER);
    }
}

/* */

$vpt = [spread*2.5,0,0];
$vpr = [0,0,0];
$vpd = 325;
