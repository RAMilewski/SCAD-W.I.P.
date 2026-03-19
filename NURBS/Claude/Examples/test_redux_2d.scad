include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//


type = "clamped"; // [closed,clamped]
count = 8;     // [4:1:25]
spread = 40;

closed_stroke =  (type == "closed");
   
//data2d = random_points(count,2,[20,20]);

data2d = [[-9.10607, -3.48], [-14.1631, 9.45862], [-3.69472, 9.46174], [-2.52846, -4.43246], [2.48644, -13.9082], [-8.85091, -1.39997], [9.5279, 3.36303], [-11.7377, -7.15573]];


echo(data2d);


path = nurbs_interp_curve(data2d, 3, splinesteps=32, method="centripetal", type=type);
color("red") move_copies(data2d) sphere(r=.5, $fn=16);
color("dodgerblue") {
    stroke(path, closed = closed_stroke, width=.2);
    fwd(20) text3d("centripetal", size = 2, h = 0.1, anchor = CENTER);
}


path2 = nurbs_interp_curve(data2d, 3, splinesteps=32, method="lockyer", type=type);
right(spread){
    color("red") move_copies(data2d) sphere(r=.5, $fn=16);
    color("black"){
        stroke(path2, closed = closed_stroke, width=.2);
        fwd(20) text3d("lockyer", size = 2, h = 0.1, anchor = CENTER);
    }
}

path3 = nurbs_interp_curve(data2d, 3, splinesteps=32, method="length", type=type);
right(spread*2){
    color("red") move_copies(data2d) sphere(r=.5, $fn=16);
    color("gold"){
        stroke(path3, closed = closed_stroke, width=.2);
         fwd(20) text3d("length", size = 2, h = 0.1, anchor = CENTER);
    }
}

path4 = nurbs_interp_curve(data2d, 3, splinesteps=32, method="dynamic", type=type);
right(spread*3){
    color("red") move_copies(data2d) sphere(r=.5, $fn=16);
    color("pink"){
        stroke(path4, closed = closed_stroke, width=.2); 
        fwd(20) text3d("dynamic", size = 2, h = 0.1, anchor = CENTER);
    }
}

path5 = nurbs_interp_curve(data2d, 3, splinesteps=32, method="foley", type=type);
right(spread*4){
    color("red") move_copies(data2d) sphere(r=.5, $fn=16);
    color("purple"){ 
        stroke(path5, closed = closed_stroke, width=.2);
        fwd(20) text3d("foley", size = 2, h = 0.1, anchor = CENTER);
     }
}


path6 = smooth_path(data2d, splinesteps = 32);
right(spread*5){
    color("red") move_copies(data2d) sphere(r=.5, $fn=16);
    color("limegreen"){ 
        stroke(path6, closed = closed_stroke, width=.2);
        fwd(20) text3d("smooth path", size = 2, h = 0.1, anchor = CENTER);
    }
}


$vpt = [spread*2.5,0,0];
$vpr = [0,0,0];

/* */