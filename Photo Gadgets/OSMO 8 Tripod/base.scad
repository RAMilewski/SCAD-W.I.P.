include<BOSL2/std.scad>
include<BOSL2/screws.scad>
include<BOSL2/threading.scad>

theta = 35;       //[25:2.5:45]
leg_length = 125; //[50:5:200]
end_ratio = 0.6;  //[.2:.1:1]
r_top = 20;

/* [Hidden] */

$fn = 72;
$slop = 0.1;
core = [38,52];
leg = [7,15,leg_length];       
leg_rnd = leg.x/10;
leg_shape = rect([leg.x,leg.y], rounding = leg_rnd);
end_shape = rect([leg.x,leg.y * end_ratio], rounding = leg_rnd);
hingepin = 3.1;


//left_half() 
//center();
//locknut();
//leg();
mount_rod(25);
//complete();



module complete(){
    xrot(180) zrot(90) down(core.x) center();
    right(r_top*3) up(leg.x/2) back(leg.z/2) rot([90,90,0]) leg();
    right(r_top*3+leg.y) up(leg.x/2)  fwd(leg.z/2) rot([90,90,180]) leg();
    right(r_top*3+leg.y*2) up(leg.x/2) back(leg.z/2) rot([90,90,0]) leg();
}


module center() {
    shape = hexagon(id = core.y, rounding = 3);
    shape2 = hexagon(id = core.y*.95, rounding = 3);
    shape3 = circle(r_top);

    diff() {
        skin([ shape, shape2, shape3], z=[0,core.x-12, core.x], slices=0, refine=1, method="reindex"){
            zrot_copies(n = 3) 
                position(CTR) down(5) back(3) tag("remove") zrot(30) ycyl(h = leg.x+$slop, d = leg.y+1, anchor = LEFT){
                        //back(10) ycyl(h = core.y, d = hingepin);
                        back(10) rot([0,90,90]) screw_hole("M3,15", head="socket", counterbore=25);
                        yrot(theta) cuboid([core.y/2,leg.x+$slop,leg.y+$slop], rounding = leg_rnd, anchor = LEFT);
                        cuboid([core.x/2,leg.x+$slop,core.x/2], anchor = TOP);
                }
            position(TOP) tag("remove") cyl(h = 18, d = 7.5, rounding1 = 2, anchor = TOP);   
            position(BOT) tag("remove") cyl(h = 15, d = 5, anchor = BOT);   
        }
    }
}


module leg() {
    diff() {
        skin([leg_shape, end_shape], z = [0,leg.z],  method="reindex", slices=10){
            position(TOP) xcyl(h = leg.x, d = leg.y * end_ratio, rounding = leg_rnd);
                position(BOT) xcyl(h = leg.x, d = leg.y, rounding = leg_rnd)
                    tag("remove") down(1) xcyl(d = hingepin, h = leg.x, rounding = -.75);
                    //tag("remove") xcyl(d = hingepin * 1.2, h = leg.x, rounding = -.75);
        }
    }
}

/*
module locknut() {
    r = 20;   //radius to lobe midpoint
    n = 18;     //number of lobes
    depth = 0.5;  //lobe depth
    z = 5;     //height of extrusion

    diff() {
        
        flower = [for(theta=lerpn(0,360,360,endpoint=false)) (r+depth*sin(n*theta))*[cos(theta),sin(theta)]];
        linear_sweep(flower,z);
        tag("remove") threaded_rod(l = z, pitch = 1/20*INCH, d = 1/4*INCH, end_len = 1, internal = true, anchor = BOT);
    }
}

*/

module mount_rod(length) {
    threaded_rod(l = length, pitch = 1/20*INCH, d = 1/4*INCH, end_len = 1, anchor = BOT);
}

/* */