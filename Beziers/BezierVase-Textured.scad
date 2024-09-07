include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <shapeset.scad>
include <TEX/VSC-4weave.data>
$fn = 72;
shape = 2;  // 0,1,2,3,4,5,6,7
bez = shapeset[shape];

wall = 3;
floor = 2;

tex_range = [0.33,0.83];
texreps = [24,2];
texdepth = 0.5;

ulat = ((tex_range.y - tex_range.x)/2 + tex_range.x);
toplat = bezier_points(bez,1).y;
lat = toplat * ulat;
pos = bezier_points(bez,ulat);
r = pos.x;
side = 2 * r * sin(180/$fn);
apothem = r * cos(180/$fn);
tanvec = bezier_tangent(bez, ulat);
tilt = 90 - v_theta(tanvec);


echo("bezier: ",bez);
echo("ulat, lat, toplat, r, side, apothem");
echo(ulat, lat, toplat, r, side, apothem);
echo("tanvec, tilt");
echo(tanvec, tilt);


object();

module object() {
    if (texdepth > 0) {
        body();
        texture(tex_range);
    } else {
        difference() {
            body();
            texture(tex_range);
        }
    }
}

module body() { 
    path = bezier_points(bez, [0:0.01:1]);
    region = concat(path,reverse(offset(path,delta=wall)));
    diff() {
        rotate_sweep(region, 360, spin = 180/$fn); 
     // Add floor 
        u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);
        cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, 
            spin = 180/$fn, anchor = BOT);  
     //Remove offset below bezier
        tag("remove") cyl(r = bez[0].x, h = wall, anchor = TOP);
    // Remove offset above bezier
        up(bez[len(bez)-1].y) 
        tag("remove") cyl(r = bez[len(bez)-1].x, h = wall, anchor = BOT);
    }
}

module texture(tex_range) {
    if(texdepth){
        path = bezier_points(bez, [tex_range[0]:0.01:tex_range[1]]);
        region = concat(path,reverse(offset(path,delta=0.01)));
        rotate_sweep(region, 360, texture = texture, tex_reps = texreps, tex_depth = abs(texdepth));
    }
}

/*  Attempt at texturing low $fn vases.   Here there be dragons.

module tex_panel(tex_range) {
    path = bezier_points(bez, [tex_range[0]:0.01:tex_range[1]]);
    region = concat(path,reverse(offset(path,delta=0.0001)));
    //zrot_copies(n = $fn, sa = 0)
       back(side/2) yrot(-tilt) color("red") linear_sweep(region, side, orient = FWD);
    up(lat) zrot_copies(n = $fn, r = apothem, sa = 0)
        color("blue") sphere(2, $fn = 64);
}

  */