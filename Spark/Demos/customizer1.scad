include<BOSL2/std.scad>

/* [Cube] */
base = [40,40,40];   //[10:5:40]

/* [Sphere] */
$fn = 32;            //[3:72]
dia = 30;            //[10:30]
position = [0,0,0];  //[-1:1:1]
anchor =  [0,0,0];   //[-1:1:1]


//ghost_this()
 cuboid(base)
    position(position) up(0) cuboid(dia, anchor = anchor);


