include<BOSL2/std.scad>


theta = 35;       //[25:2.5:45]
leg_length = 125; //[50:5:200]
end_ratio = 0.4;  //[.2:.1:1]
r_top = 12;

/* [Hidden] */

$fn = 72;
$slop = 0.1;
core = [40,42];
leg = [5,15,leg_length];       
leg_rnd = leg.x/10;
leg_shape = rect([leg.x,leg.y], rounding = leg_rnd);
end_shape = rect([leg.x,leg.y * end_ratio], rounding = leg_rnd);
hingepin = 2;


//left_half() center();
//complete();
//locknut();
leg();




module complete(){
    xrot(180) down(core.x) center();
    right(r_top*2) up(leg.x/2) back(leg.z/2) rot([90,90,0]) leg();
    right(r_top*2+leg.y) up(leg.x/2)  fwd(leg.z/2) rot([90,90,180]) leg();
    right(r_top*2+leg.y*2) up(leg.x/2) back(leg.z/2) rot([90,90,0]) leg();
}


module center() {
    shape = hexagon(id = core.y, rounding = 3);
    shape2 = hexagon(id = core.y*.8, rounding = 3);
    shape3 = circle(r_top);

    diff() {
        skin([ shape, shape2, shape3], z=[0,core.x-12, core.x], slices=0, refine=1, method="reindex"){
            zrot_copies(n = 3) 
                position(CTR) down(5) tag("remove") zrot(30) ycyl(h = leg.x+$slop, d = leg.y+1, anchor = LEFT){
                        back(10) ycyl(h = core.y, d = hingepin);
                        yrot(theta) cuboid([core.y/2,leg.x+$slop,leg.y+$slop], rounding = leg_rnd, anchor = LEFT);
                        cuboid([core.x/2,leg.x+$slop,leg.y], anchor = TOP);
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
                    tag("remove") xcyl(d = hingepin * 1.2, h = leg.x, rounding = -.75);
        }
    }
}

module locknut() {
    flower = [for(theta=lerpn(0,360,180,endpoint=false))
          (15+1.3*sin(6*theta))*[cos(theta),sin(theta)]];
    linear_sweep(flower,10);

}