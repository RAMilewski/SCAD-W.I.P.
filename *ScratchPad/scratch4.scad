// Cookie cutter roller
// Optimized for use with img2tex.py and 250x300 px images  

include<BOSL2/std.scad>
include<BOSL2/threading.scad>
include<bunny.data>
$fn=144;

r = 16;
h = 50;
depth = 5;
tex_depth = 3;
r_rod = 6;


h_size = 18;
h_round = 5;
h_fudge = 5; 
handle = [100, h_size, h_size];
forkA = [h_size, h + h_size + h_fudge, h_size];
forkB = [25 + r + r_rod, h_size, h_size];

test();


module handle() {

    diff() {
        cuboid(handle, rounding = h_round, teardrop = true, except = RIGHT, anchor = RIGHT)
            position(RIGHT) left(h_round) cuboid(forkA, rounding = h_round, teardrop = true, except = [FWD,BACK], anchor = LEFT) {
                
                    align([BACK+RIGHT]) left(h_size) fwd(h_round) cuboid(forkB, rounding = h_round, teardrop = true, except = RIGHT) 
                        position(RIGHT){
                            ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") left(1) ycyl(r = r_rod, h = h_size*1.5);
                        }
                
                   
                    align([FWD+RIGHT]) left(h_size) back(h_round) cuboid(forkB, rounding = h_round, teardrop = true, except = RIGHT)
                        position(RIGHT){
                            ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") back(2)left(1) acme_threaded_rod(
                                                    d=r_rod * 2, l= h_size-2, pitch=4, $fn=72, internal=true, bevel=true,
                                                    blunt_start=false, teardrop=true, orient=FWD );
                        }
                
            }
    }

}


module axle () {

}


module roller() {   
    diff() {
        //cyl(h, r, anchor = BOT) {
        cyl(h, r, texture = bunny,  tex_reps = [3,1], tex_depth = tex_depth, anchor = BOT) {
            zrot_copies(n=3) attach(RIGHT) prismoid([depth/2,h], [0,h], depth);
            attach(BOT) cyl(depth * .66, r1 = r, r2 = r * depth, anchor = TOP);
            attach(TOP) cyl(depth * .66, r1 = r, r2 = bar.y/2, anchor = TOP);
        }
        tag("remove") cyl(h+bar.x*2, r_rod+0.5, anchor = BOT);
    }
}

module test() {
            diff(){
            
                     left(h_size) back(h_round) cuboid(forkB, rounding = h_round, teardrop = true, except = RIGHT)
                        position(RIGHT){
                            ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") left(1) acme_threaded_rod(
                                                    d=r_rod * 2, l= h_size, pitch=4, $fn=72, internal=true, bevel=true,
                                                    blunt_start=false, teardrop=false, orient=FWD );
                        }
                }

}