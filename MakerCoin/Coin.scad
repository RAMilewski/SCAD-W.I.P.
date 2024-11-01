include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 144;

function cpd(r) = r * (4/3) * tan(180/8); // Control pt distance for quarter round.


r1 = 25;    // Major radius of the coin
r2 = 5;     // radius of the edge
cz = 1;     // center z max

body = bezpath_curve(flatten([
    bez_begin([0, -r2], RIGHT, 10),
    bez_tang ([r1-r2,-r2], 0, cpd(r2)),
    bez_tang ([r1,0], 90, cpd(r2)),
    bez_tang ([r1-r2, r2], 180, cpd(r2)),
    bez_end([0,cz], RIGHT, 12),
]));

edgefit = 9.5;

edge = bezpath_curve(flatten([
        bez_begin(cylindrical_to_xyz(r1+r2-edgefit,0,r2),FWD,4),
        bez_tang (cylindrical_to_xyz(r1,-14.5,0),DOWN,4.1),
        bez_tang (cylindrical_to_xyz(r1+r2-edgefit,0,-r2),BACK,4),
        bez_tang (cylindrical_to_xyz(r1,14.5,0),UP,4.1),
        bez_end  (cylindrical_to_xyz(r1+r2-edgefit,0,r2),BACK,4)
]));

//debug_bezier(edge, width = 0.2);


mask =  zrot(0,mask2d_roundover(2, mask_angle = 90, inset = 0));

norm = [-.15,.6,0];

right(r1) anchor_arrow(s = 5, color = [1,.5,.5], orient = norm, flag = false);

module test() {
    attachable(){
        diff(){
            rotate_sweep(body,360);
                *tag("remove") text3d("OS", font = "Arial:bold", size = 14, h = r2, anchor = CENTER+BOT, atype = "ycenter");
                zrot_copies(n = 8) {
                    tag("remove") right(27.5) cyl(h = r2*2, r = 7);
                    tag("remove") path_sweep(mask, edge, method = "manual", normal=-edge,  closed = true);
                }
            }
        children();
    }
}

pts = bezier_points(edge, [ for (i = [0 : 1/16 : 1]) i ]);
rainbow(pts) move($item) echo($item) sphere(0.2, $fn=36);



//right(30) zrot(-45) stroke(path3d(mask), width = .2);

arc1 = right(r1-r2,yrot(0,xrot(90,path3d(arc(d = 10, angle = [-90,90])))));
color("blue") stroke(arc1, width = 0.1);

//back_half(s = 200) 
test();

//debug_bezier(edge, width = 0.2);

path = bezpath_curve(edge, splinesteps = 16);
color("purple") stroke(path, closed=true, width=0.1);
normals = path_normals(path,closed=true);
color("purple")
    *for(i=[0:len(normals)-1])
        stroke([path[i]-normals[i], path[i]+normals[i]],width=.1, endcap2="arrow2");



//right(60) down(5) import("OSmakercoin.stl");



/*
 */