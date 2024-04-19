// Cookie cutter roller
// Optimized for use with img2tex.py and 250x300 px images  
// Pixabay.com is a source for images.

// use image2tex.py -o texture.data ... <imagefile>

include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <texture.data>
$fn=72;

part = "handle";            // roller, handle, axle, ring, test
texturize = false; 
debug = false;               // Show rulers  

dough = 5;                  // Dough Thickness
cookie = [40,50];           // Cookie Size [width, height]
tex_depth = -3;             // Texture Depth ( + or - )
c_reps = 3;                 // Cookies/Revolution
tex_reps = [c_reps,1];      // Texture Repetition  (usually [c_reps,1] except for multiple different images)


//Roller Parameters
v_margin = dough + 2;          // Top + Bottom Cutter Margin
h = cookie.y + v_margin;       // Roller Height
r = (cookie.x+2)*c_reps/PI/2;  // Roller Radius  
roller_ease = 0.5;               // Roller Hole Extra Size

//Handle & Axle Parameters
r_max = 30;         // Max roller radius that will fit in handle.
r_rod = 6;          // Axle radius
h_size = 18;        // Handle width & height
h_round = 5;        // Handle Rounding
h_end = 5;          // Handle clearance for roller ends 
handle = [100, h_size, h_size];
fork_y = [h_size, h + h_size/2 + h_end, h_size];
fork_x = [h_size + r_max + r_rod + 2, h_size, h_size];


// Rolling Pin Ring Parameters
id_ring = 42;
h_ring = 7;
ring_wall = dough;

$slop = 0.1;        //Printer dependant fudge factor for hole sizing.
null_tex = [[1,1,1,1], [1,1,1,1], [1,1,1,1], [1,1,1,1]];




echo(str("Roller Radius = ",r,"mm"));
circum = ((PI*r*2) - 2*c_reps); // Circumference of roller image area (minus vcut bars)
echo(str("Cookie Size = ",cookie.x," X ",cookie.y,"mm"));
aspect1 = (PI*r*2)/cookie.y;    //aspect ratio of image area including margins for vcuts
echo(str("Image area aspect ratio = ",aspect1,":1"));
aspect2 = ((circum/c_reps)/cookie.y);  //single pane aspect ratio
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
        cyl(h = cookie.y, r = r, texture = texture,  tex_reps = tex_reps, tex_depth = tex_depth, anchor = BOT) {
            //Vertical Cutters
            zrot_copies(n=c_reps) attach(RIGHT) prismoid([2,h], [0.5,h], dough);
            //Top Cutter
            position(TOP) cyl(dough/2, r1 = r, r2 = r + dough, anchor = BOT)
                position(TOP) cyl(1, r = r + dough, anchor = BOT);
            //Bottom Cutter
            position(BOT) cyl(dough/2, r1 = r + dough, r2 = r, anchor = TOP)
                position(BOT) cyl(1, r = r + dough, anchor = TOP);
        }
        // Axle Hole
        tag("remove") down(dough) cyl(h+2, r_rod + roller_ease + $slop * 2, circum = true, anchor = BOT);
    }
    if (debug) up(54) left(50) ruler();
}


module handle() {

echo("A : ",fork_y);
echo("B : ",fork_x);

    diff() {
        cuboid(handle, rounding = h_round, teardrop = true, except = RIGHT, anchor = RIGHT)
            position(RIGHT) left(h_round) cuboid(fork_y, rounding = h_round, teardrop = true, except = [FWD,BACK], anchor = LEFT) {
                
                    align([FWD+RIGHT]) left(h_size) back(h_round) cuboid(fork_x, rounding = h_round, teardrop = true, except = RIGHT) 
                        position(RIGHT){
                            xscale(0.8) yrot(30) ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") left(3) ycyl(r = r_rod + $slop * 2, circum = true, h = h_size*1.5);
                        }
                    align([BACK+RIGHT]) left(h_size) fwd(h_round) cuboid(fork_x, rounding = h_round, teardrop = true, except = RIGHT)
                        position(RIGHT){
                            xscale(0.8) ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") fwd(2)left(3) acme_threaded_rod(
                                                    d=r_rod * 2, l= h_size-2, pitch=4, internal=true, bevel=true,
                                                    blunt_start=false, teardrop=false, orient=FWD );
                            if (debug) tag("keep") fwd(fork_y.y/2 + 4) rot(00) ruler(anchor = CENTER);
                        }
                
            }
    }


}


module axle () {
    cyl(d = h_size - 2, h = h_size/4, texture = "wave_ribs", tex_reps = [15,1], anchor = TOP)
        attach(TOP) cyl(r = r_rod, h = fork_y.y + h_size/2, anchor = BOT)
            attach(TOP) xrot(90) acme_threaded_rod(
                            d=r_rod * 2, l= h_size-2, pitch=4, $fn=72, bevel=true,
                            blunt_start=false, orient=FWD );
    if (debug) right(r_rod) rot([0,-90,90]) ruler();        

}

module ring () { 
    difference(){
        tube (id = id_ring, wall = ring_wall, h = h_ring);
        fwd (id_ring/2 + ring_wall/2) yrot(45) cuboid([1, h_ring, h_ring * 2]);
    }
}


module test() {
    diff() {
           cuboid(fork_x, rounding = h_round, teardrop = true, except = RIGHT) 
                        position(RIGHT){
                            xscale(0.8) yrot(30) ycyl(d = h_size, h = h_size, rounding = h_round);
                            tag("remove") left(2) ycyl(r = r_rod + $slop, circum = true, h = h_size*1.5);
                        }
    }
}
