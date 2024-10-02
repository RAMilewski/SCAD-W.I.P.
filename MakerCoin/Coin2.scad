include<BOSL2/std.scad>
include<BOSL2/beziers.scad>
include<BOSL2/rounding.scad>

$fn = 144;

function cpd(r) = r * (4/3) * tan(180/8); // Control pt distance for quarter round.


r1 = 25;    // Major radius of the disc
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

edgepath = bezpath_curve(flatten([
        bez_begin(cylindrical_to_xyz(r1+r2-edgefit,0,r2),FWD,4),
        bez_tang (cylindrical_to_xyz(r1,-14.5,0),DOWN,4.1),
        bez_tang (cylindrical_to_xyz(r1+r2-edgefit,0,-r2),BACK,4),
        bez_tang (cylindrical_to_xyz(r1,14.5,0),UP,4.1),
        bez_end  (cylindrical_to_xyz(r1+r2-edgefit,0,r2),BACK,4)
]));



module test() {
    diff(){
        rotate_sweep(body,360);
            zrot_copies(n = 8) {
                //tag("remove") right(27.5) cyl(h = r2*2, r = 7);
                tag("remove") right(27.5) join_prism(circle(r=7),base="cyl",base_r=-25, n=15,
                aux="cyl",prism_end_T=fwd(0),aux_r=-5,fillet=7, overlap=17);
            }
    }
}

/*difference(){
     xcyl(r=30,l=100,circum=true);
     join_prism(circle(r=15),base="cyl",base_r=-30, n=15,
                aux="cyl",prism_end_T=fwd(9),aux_r=-30,fillet=7, overlap=17);
   }
*/


//back_half(s = 200) 
test();




/*

pts = bezier_points(edge, [ for (i = [0 : 1/16 : 1]) i ]);
rainbow(pts) move($item) echo($item) sphere(0.2, $fn=36);

arc1 = right(r1-r2,yrot(0,xrot(90,path3d(arc(d = 10, angle = [-90,90])))));
color("blue") stroke(arc1, width = 0.1);


//debug_bezier(edge, width = 0.2);

path = bezpath_curve(edge, splinesteps = 16);
color("purple") stroke(path, closed=true, width=0.1);
normals = path_normals(path,closed=true);
color("purple")
    *for(i=[0:len(normals)-1])
        stroke([path[i]-normals[i], path[i]+normals[i]],width=.1, endcap2="arrow2");



//right(60) down(5) import("OSmakercoin.stl");



 */