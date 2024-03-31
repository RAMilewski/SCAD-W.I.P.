// Cookie cutter roller
// Optimized for use with img2tex.py and 250x300 px images  
// Pixabay.com is a source for images.

// use image2tex.py -o texture.data ... <imagefile>

include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <texture.data>
$fn=72;
$slop = 0.25;

part = "handle";    // roller, handle, axle, ring, test

r = 16;             // Roller Radius
h = 50;             // Roller Height
depth = 4;          // Dough Thickness
tex_depth = 3;      // Texture Depth ( + or - )
tex_reps = [1,1];   //Image Layout

r_max = 25;         //Max roller radius the will fit in handle.
r_rod = 6;          //Axle radius
h_size = 18;        //Handle width & height
h_round = 5;        //Handle Rounding
h_fudge = 2;        //Handle clearance for roller ends 
h2 = h - depth - 2; // Height of roller image area
handle = [100, h_size, h_size];
forkA = [h_size, h + h_size/2 + h_fudge, h_size];
forkB = [h_size + r_max + r_rod +2, h_size, h_size];

id_ring = 42;
h_ring = 10;
ring_wall = 5;




if (part == "roller")   { roller(); }
if (part == "handle")   { handle(); }
if (part == "axle")     { axle(); }
if (part == "ring")     { ring(); }
if (part == "test")     { test(); }



module roller() {   
    diff() {
        cyl(h2, r, anchor = BOT) {
        //cyl(h2, r, texture = texture,  tex_reps = tex_reps, tex_depth = tex_depth, anchor = BOT) {
            zrot_copies(n=3) attach(RIGHT) prismoid([2,h], [0.5,h], depth);
            position(TOP) cyl(depth/2, r1 = r, r2 = r + depth, anchor = BOT)
                position(TOP) cyl(1, r = r + depth, anchor = BOT);
            position(BOT) cyl(depth/2, r1 = r + depth, r2 = r, anchor = TOP)
                position(BOT) cyl(1, r = r + depth, anchor = TOP);
        /*
            } */
        }
        tag("remove") cyl(h, r_rod + 2 * $slop, anchor = BOT);
    }
}


module handle() {

    diff() {
        cuboid(handle, rounding = h_round, teardrop = true, except = RIGHT, anchor = RIGHT)
            position(RIGHT) left(h_round) cuboid(forkA, rounding = h_round, teardrop = true, except = [FWD,BACK], anchor = LEFT) {
                
                    align([FWD+RIGHT]) left(h_size) fwd(h_round) cuboid(forkB, rounding = h_round, teardrop = true, except = RIGHT) 
                        position(RIGHT){
                            xscale(0.8) ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") left(2) ycyl(r = r_rod + 2 * $slop, h = h_size*1.5);
                        }
                    align([BACK+RIGHT]) left(h_size) back(h_round) cuboid(forkB, rounding = h_round, teardrop = true, except = RIGHT)
                        position(RIGHT){
                            xscale(0.8) ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") fwd(2)left(2) acme_threaded_rod(
                                                    d=r_rod * 2, l= h_size-2, pitch=4, internal=true, bevel=true,
                                                    blunt_start=false, teardrop=false, orient=FWD );
                        }
                
            }
    }

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
        tube (id = id_ring, wall = ring_wall, h = 10);
        fwd (id_ring/2 + ring_wall/2) yrot(45) cuboid([1, h_ring, h_ring * 2]);
    }
}





module test() {
            cyl(h2, r, anchor = BOT) 
            //cyl(h2, r, texture = texture,  tex_reps = tex_reps, tex_depth = tex_depth, anchor = BOT) {
                zrot_copies(n=3) attach(RIGHT) prismoid([2,h2], [0.5,h2], depth);

}

