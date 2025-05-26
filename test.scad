include <BOSL2/std.scad>
//cuboid([40,20,3])
   //align(TOP,RIGHT)  
   
 //  zrot (180/8) 

 $fn = 144;
theta = 50;

 //onion(d = 20, ang = theta, cap_h = 20, realign = true);
 //color("blue") spheroid(d = 25);
//up(25) ruler();
path = right(20 * cos(theta), mask2d_roundover(r = 5, mask_angle= theta);
mask = rotate_sweep(path, 360);

/*
theta = 25;
onion(r = 10, cap_h = 15, ang = theta)
position("cap")cuboid(10, anchor = BOT);
//right(11.3) xrot(90) zrot(90+theta) ruler();


/* */