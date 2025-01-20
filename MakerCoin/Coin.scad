include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fs = 1;
$fa = 1;

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

edgebez = flatten([
        bez_begin(cylindrical_to_xyz(r1+r2-edgefit,0,r2),FWD,4),
        bez_tang (cylindrical_to_xyz(r1,-14.5,0),DOWN,4.1),
        bez_tang (cylindrical_to_xyz(r1+r2-edgefit,0,-r2),BACK,4),
        bez_tang (cylindrical_to_xyz(r1,14.5,0),UP,4.1),
        bez_end  (cylindrical_to_xyz(r1+r2-edgefit,0,r2),BACK,4)
]);

edge = bezpath_curve(edgebez);

debug_bezier(edgebez, width = 0.2);

move_copies(bezier_curve(edgebez, 32)) sphere(r=.1);

//back_half(s = 200) 
ghost() coin();


module coin() {
    attachable(){
        diff(){
            rotate_sweep(body,360);
                *tag("remove") text3d("OS", font = "Arial:bold", size = 14, h = r2, anchor = CENTER+BOT, atype = "ycenter");
                zrot_copies(n = 8) {
                    tag("remove") right(27.5) cyl(h = r2*2, r = 7);
                }
            }
        children();
    }
}




//back_half(s = 200) 
ghost() coin();


//right(60) down(5) import("OSmakercoin.stl");



/*
 */