include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <shapeset.scad>
include <TEX/texture.data>
$fn = 64;
shape = 0;
bez = shapeset[shape];

wall = 3;
floor = 2;
is2d = false;

texreps = [10,2];
texdepth = 0.25;
 
ucut = [0,0.70,0.78,1];

echo(bez);


back_half(s = 300) 
object();

module object() {
    diff() {
        smooth   (ucut[0],  ucut[3], is2d);
        color("skyblue") textured (ucut[1],  ucut[2], is2d);
        //smooth   (ucut[2],  ucut[3], is2d);
        // Add floor and remove offset below bez[0].y
        u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);
        if (!is2d) {
            cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, anchor = BOT);
            tag("remove") cyl(r = bez[0].x, h = wall, anchor = TOP);
        // Remove offset above top of bez[len(bez)-1].y]
        up(bez[len(bez)-1].y) 
            tag("remove") cyl(r = bez[len(bez)-1].x, h = wall, anchor = BOT);
        }
    }
}

module test() {
    path = bezier_points(bez, [umin:0.01]);
}



module smooth(umin,umax,is2d) { 
    path = bezier_points(bez, [umin:0.01:umax]);
    region = concat(path,reverse(offset(path,delta=wall)));
    if(is2d) {
        stroke(region, width = 0.2);
    }else{
        rotate_sweep(region,360);
    }
}

module textured(umin,umax,is2d) {
    path = bezier_points(bez, [umin:0.01:umax]);
     region = concat(path,reverse(offset(path,delta=wall)));
    if(is2d) {
        stroke(region, width = 0.2);
    }else{
        rotate_sweep(path, 360, texture = texture, tex_reps = texreps, tex_depth = texdepth, closed = true);
    }
}


 /*
 

  */