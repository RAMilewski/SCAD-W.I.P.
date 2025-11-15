include<BOSL2/std.scad>

$fn = 72;
$slop = 0.1;

core = [40,40];
theta = 35;       //leg angle
leg_xy = [5,15];       
leg_rnd = leg_xy.x/4;
leg_shape = rect(leg_xy, rounding = leg_rnd);
hingepin = 2.25;

leg(125);  
//left_half()
//center();


module center() {
    shape = hexagon(id = core.y, rounding = 3);
    shape2 = hexagon(id = core.y*.8, rounding = 3);
    shape3 = circle(10);

    diff() {
        skin([ shape, shape2, shape3], z=[0,core.x-3, core.x], slices=0, refine=1, method="reindex"){
            zrot_copies(n = 3) 
                position(CTR) tag("remove") zrot(30) #ycyl(h = leg_xy.x, d = leg_xy.y, anchor = LEFT){
                        back(10) #ycyl(h = core.y, d = hingepin);
                        yrot(theta) cuboid([core.y,leg_xy.y+$slop,leg_xy.y+$slop], rounding = leg_rnd, anchor = LEFT);
                        yrot(60) cuboid([core.y,leg_xy.x+$slop,leg_xy.y+$slop], rounding = leg_rnd, anchor = LEFT);
                        yrot(90) cuboid([core.y,leg_xy.x+$slop,leg_xy.y+$slop], rounding = leg_rnd, anchor = LEFT);
                }
            position(TOP) tag("remove") cyl(h = 20, d = 7.5, anchor = TOP);   
        }
    }
}


module leg(length) {
    ellipse =  yscale(1.5, p = circle(r =2, $fn = 128));
    diff() {
        skin([leg_shape, leg_shape, ellipse], z = [0,leg_xy.y/2,length],  method="reindex", slices=10){
            position(TOP) yscale(1.5) spheroid(2);
                position(BOT) xcyl(h = leg_xy.x, d = leg_xy.y, rounding = leg_rnd)
                    tag("remove") xcyl(d = hingepin, h = leg_xy.x, rounding = -.75);
        }
    }
}