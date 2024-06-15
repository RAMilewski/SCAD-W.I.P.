include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <shapeset.scad>
include <TEX/VSC-4weave.data>
$fn = 66;
shape = 4;
bez = shapeset[shape];

wall = 3;
floor = 2;

texrange = [0.23,0.43];
texreps = [10,2];
texdepth = 0.25;
 
echo(bez);

 object() show_anchors();

module object() {
    if (texdepth > 0) {
        *body();
        textured(texrange[0],  texrange[1]);
    } else {
        difference() {
            body();
            textured(texrange[0],  texrange[1]);
        }
    }
}

module body() { 
    path = bezier_points(bez, [0:0.01:1]);
    region = concat(path,reverse(offset(path,delta=wall)));
    diff() {
        rotate_sweep(region,360); 
     // Add floor 
        u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);
        cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, anchor = BOT);  
     //Remove offset below bezier
        tag("remove") cyl(r = bez[0].x, h = wall, anchor = TOP);
    // Remove offset above bezier
        up(bez[len(bez)-1].y) 
        tag("remove") cyl(r = bez[len(bez)-1].x, h = wall, anchor = BOT);
    }
}

module textured(umin,umax) {
    path = bezier_points(bez, [umin:0.01:umax]);
    region = concat(path,reverse(offset(path,delta=0.0001)));
    *linear_sweep(region, 40, texture = texture, tex_reps = texreps, tex_depth = abs(texdepth));
    stroke(region);
}


 /*
 

  */