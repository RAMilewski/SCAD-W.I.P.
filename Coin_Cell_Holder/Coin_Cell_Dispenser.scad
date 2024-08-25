include<BOSL2/std.scad>
include<BOSL2/threading.scad>

batt_idx = 5; // [0:CR2477, 1:CR2032, 2:CR2025, 3:CR2016, 4:LR44, 5:TCap] 
part = "all"; // [all,body,top,plunger,assembly]

/* [Hidden] */
$fn = 72;

// Springs  [od, id, length, compressed, McMaster's part#]
springs = [ 
    [0.688 * INCH, 0.529 * INCH, 3 * INCH, 1.129 * INCH, "9657K124"],
    [0.360 * INCH, 0.258 * INCH, 3 * INCH, 1.132 * INCH, "9657K427"],
];

// Batteries  [xdim, undef, zdim, spring, slotZ, label]
batts = [
    [24.5, undef, 7.7, 0, 4, "CR2477"],
    [20.5, undef, 3.2, 0, 4, "CR2032"],
    [20.5, undef, 2.5, 0, 4, "CR2025"],
    [20.5, undef, 1.6, 0, 4, "CR2016"],
    [11.6, undef, 5.5, 1, 4, "LR44"],
    [19.5, undef, 2.5, 0, 0, "Chris"]
];

batt = batts[batt_idx];
echo (batt);


// Dimensions
wall = 6;
body = [batt.x + (wall * 2), undef, 3 * INCH];
top = [body.x, undef, body.z/6 + 10];
floor = 3;
bevel = 2;
batt_slop = 0.5;
spring_slop = 0.25; 

if (part == "top")  { top(); } 
if (part == "body") { body(); } 
if (part == "plunger") { back_half() plunger(); }
if (part == "all")  { left(body.x) body(); right(body.x) top(); plunger(); }
if (part == "assembly") {
        back_half(s=200) body(); 
        up(body.z) yrot(180) color("skyblue") back_half(s = 200) top();
        up(10) color("blue") springs(); 
        up(body.z - 5) color("green") yrot(180) plunger();
}

module top() {
    diff(){
        cyl(h = top.z, d = top.x, rounding1 = 4, teardrop = true, anchor = BOT) {
            tag("remove") position(TOP) {
                zrot(140) acme_threaded_rod(d=body.x - wall, l = top.z/2, pitch=1/8*INCH, 
                    internal = true, $fn=64, $slop = 0.4, anchor = TOP);
            }
            tag("remove") position(BOT) { 
                cyl(h = top.z+0.01, d = batt.x - 3, rounding1 = -3 , teardrop = true, anchor = BOT);
                up(batt[4]) cyl(h = top.z - 3, d = batt.x + batt_slop, anchor = BOT);
                fwd(batt.x/2) up(batt[4]) #cuboid([batt.x, batt.x*2, batt.z + batt_slop], 
                    rounding = batt.x/2, edges = "Z", except = FWD, anchor = BOT);
            }
            path = path3d(arc(100, r=body.x/2, angle=[210, 360]));
            tag("Keep") position(TOP) down (2.5) yrot(180)
                path_text(path, batt[5], font="Impact", size=6, lettersize = 6);    
        }
    }
}


module body() {
    diff() {
        cyl(h = body.z * 0.75, d = body.x, anchor = BOT) {
            tag("remove")  position(BOT) up(floor) 
                cyl(h = body.z * 0.75 - floor, d = batt.x + batt_slop, anchor = BOT);  
            //path = path3d(arc(100, r=body.x/2 + 0.25, angle=[210, 360]));
            //tag("remove") position(TOP) down (10)
            //    path_text(path, batt[4], font="Impact", size=6, lettersize = 6);            
            difference() {
                position(TOP) acme_threaded_rod(d=body.x - wall, l=top.z/2, pitch=1/8*INCH, $fn=64, anchor = BOT);
                position(TOP) cyl(d = batt.x + batt_slop, l = body.z/4, anchor = BOT);
            }
            spring = springs[batt[3]];
            tag("keep") position(BOT) up(floor)  //spring post
                cyl(h = spring[3]/4, d1 = spring.y - spring_slop, d2 = spring.y*0.7, rounding2 = 2, anchor = BOT);
        }
    }
}

module plunger() {
        spring = springs[batt[3]];
        diff()
            cyl(h = 15, d = batt.x - batt_slop, rounding = bevel, teardrop = true, anchor = BOT)
                position(BOT) up(floor) tag("remove") cyl(h = 15, d = spring.x + 2 * spring_slop, anchor = BOT);
    }


module springs() {
    spring = springs[batt[3]];
    down(spring[3]/4) 
        spiral_sweep(circle(.5), h=body.z-10, d=spring[1]-2, turns=9, $fn=36, anchor = BOT);
}
  