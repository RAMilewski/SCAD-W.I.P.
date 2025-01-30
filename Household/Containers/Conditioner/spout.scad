// Fits TRESemmé 28oz. Bottle

include<BOSL2/std.scad>
include<BOSL2/bottlecaps.scad>

part = "Spout"; // [Spout, Cap, Stand]

/* [Hidden] */
$fn = 64;
$slop = 0.5;
wall = 1.5;
dia1 = 15;
dia2 = 28;
dia3 = 60;




if (part == "Spout") spout();
if (part == "Cap") cap(wall);
if (part == "Stand") cap(25);




module spout() {
    diff()
        sp_cap(dia2, 415, wall, bot_adj = 9) {
            position(BOT) down(0.25) tag("remove") cyl(h = 2, d = dia2 - 3 * wall, anchor = BOT);
            position(BOT) tube(h = 15, od1 = dia1, od2 = dia2, wall = wall , anchor = TOP)
                position(BOT) tube(h = 10, od = dia1, wall = wall, anchor = TOP);
        }
}


module cap(wall) {
    round = min(wall/2,2);
    tube(id = dia1+$slop, wall = wall, orounding = round, irounding2 = round, h = 10, anchor = BOT)
    position(BOT) cyl(h = 1, d = dia1+$slop, anchor = BOT);
}

