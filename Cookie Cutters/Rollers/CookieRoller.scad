// Cookie cutter roller
// Optimized for use with img2tex.py and 250x300 px images  
// Pixabay.com is a source for images.

// use image2tex.py -o texture.data ... <imagefile>

include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <texture.data>
$fn=72;

part = "roller";    // roller, handle, axle, ring, test
texturize = false;   

r = 18;             // Roller Radius
h = 50;             // Roller Height
depth = 5;          // Dough Thickness
tex_depth = 3;      // Texture Depth ( + or - )
tex_reps = [1,1];   // Texture Repetition
v_cuts = 3;         // Cookies/Revolution

r_max = 25;         // Max roller radius that will fit in handle.
r_rod = 6;          // Axle radius
h_size = 18;        // Handle width & height
h_round = 5;        // Handle Rounding
h_fudge = 5;        // Handle clearance for roller ends 
h2 = h - depth - 2; // Height of roller image area
handle = [100, h_size, h_size];
forkA = [h_size, h + h_size/2 + h_fudge, h_size];
forkB = [h_size + r_max + r_rod +2, h_size, h_size];

id_ring = 42;
h_ring = 7;
ring_wall = 5;

$slop = 0.1;        //Printer dependant fudge factor for hole sizing.
null_tex = [[0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0]];


cookie = [(PI*2*r)/v_cuts - 2 * v_cuts, h2];
echo(str("Cookie Size = ",cookie.x," X ",cookie.y,"mm"));
aspect1 = (2 * PI * r)/h2;    //aspect ratio of image area including margins
echo(str("Image area aspect ratio = ",aspect1,":1"));
aspect2 = (2 * PI * r - v_cuts * 2)/h2/v_cuts;  //single pane aspect ratio
echo(str("Single pane aspect ratio = ",aspect2,":1"));

if (part == "roller")   { roller(); }
if (part == "handle")   { handle(); }
if (part == "axle")     { axle(); }
if (part == "ring")     { ring(); }
if (part == "test")     { test(); }


module roller() {   
    diff() {
        texture = texturize ? texture : null_tex;
        tex_reps = texturize ? tex_reps : [18,1];  
        cyl(h2, r, texture = texture,  tex_reps = tex_reps, tex_depth = tex_depth, anchor = BOT) {
            zrot_copies(n=v_cuts) attach(RIGHT) prismoid([2,h], [0.5,h], depth);
            position(TOP) cyl(depth/2, r1 = r, r2 = r + depth, anchor = BOT)
                position(TOP) cyl(1, r = r + depth, anchor = BOT);
            position(BOT) cyl(depth/2, r1 = r + depth, r2 = r, anchor = TOP)
                position(BOT) cyl(1, r = r + depth, anchor = TOP);
        }
        tag("remove") down(depth) cyl(h+2, r_rod + $slop, circum = true, anchor = BOT);
    }
    //up(50) left(r_rod + $slop) ruler();
}


module handle() {

echo("A : ",forkA);
echo("B : ",forkB);

    diff() {
        cuboid(handle, rounding = h_round, teardrop = true, except = RIGHT, anchor = RIGHT)
            position(RIGHT) left(h_round) cuboid(forkA, rounding = h_round, teardrop = true, except = [FWD,BACK], anchor = LEFT) {
                
                    align([FWD+RIGHT]) left(h_size) back(h_round) cuboid(forkB, rounding = h_round, teardrop = true, except = RIGHT) 
                        position(RIGHT){
                            xscale(0.8) yrot(30) ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") left(2) ycyl(r = r_rod + $slop, circum = true, h = h_size*1.5);
                        }
                    align([BACK+RIGHT]) left(h_size) fwd(h_round) cuboid(forkB, rounding = h_round, teardrop = true, except = RIGHT)
                        position(RIGHT){
                            xscale(0.8) ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") fwd(2)left(2) acme_threaded_rod(
                                                    d=r_rod * 2, l= h_size-2, pitch=4, internal=true, bevel=true,
                                                    blunt_start=false, teardrop=false, orient=FWD );
                        }
                
            }
    }
//right(55) zrot(90) ruler(anchor = CENTER);

}


module axle () {
    cyl(d = h_size - 2, h = h_size/4, texture = "wave_ribs", tex_reps = [15,1], anchor = TOP)
        attach(TOP) cyl(r = r_rod, h = forkA.y + h_size/2, anchor = BOT)
            attach(TOP) xrot(90) acme_threaded_rod(
                            d=r_rod * 2, l= h_size-2, pitch=4, $fn=72, bevel=true,
                            blunt_start=false, orient=FWD );

}

module ring () { 
    difference(){
        tube (id = id_ring, wall = ring_wall, h = h_ring);
        fwd (id_ring/2 + ring_wall/2) yrot(45) cuboid([1, h_ring, h_ring * 2]);
    }
}


module test() {
    diff() {
           cuboid(forkB, rounding = h_round, teardrop = true, except = RIGHT) 
                        position(RIGHT){
                            xscale(0.8) yrot(30) ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") left(2) ycyl(r = r_rod + $slop, circum = true, h = h_size*1.5);
                        }
    }
}
