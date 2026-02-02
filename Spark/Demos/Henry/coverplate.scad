include<BOSL2/std.scad>

obj = [80,40,4];
clearance = 0.5;
delta = 2 * (clearance + obj.z);
rail = [obj.x + 2 * clearance, obj.z, 3];

cuboid(obj + [delta,delta,0], anchor = BOT)
    align(TOP,[BACK,FWD]) cuboid(rail, anchor = BOT);


