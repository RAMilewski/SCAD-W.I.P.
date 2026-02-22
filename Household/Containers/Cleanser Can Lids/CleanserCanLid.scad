include<BOSL2/std.scad>

/* [Hidden] */
$fn = 144;
BF = [77,75];  //Bartender's Friend
Comet  = [99,90];  //Comet ...not real numbers
BonAmi = [80,78];  //BonAmi ...not real numbers

/* [Global] */
can = BF;  // [1:BF 2:Comet, 3:BonAmi]


cyl(h = 1, d = can.x, anchor = BOT)
    position(TOP) tube(od = can.x, id = can.y, h = 10,anchor = BOT);