include<BOSL2/std.scad>
$fn = 72;

/* [Gargoyle Settngs] */
gargoyle = 14;   // [1:23]
size = 0.32;  //[.20:.01:1]
spin = 0;    //[-10:10]
offset = 2.2;  //[0:0.1:10]
sink = 3;    //[0:0.5:5]

import = str("../Gargoyles/Gargoyle_",format2(gargoyle),"_MOD.stl");

prismoid([7,23],[8,23], h = 10, rounding1 = 3.5, rounding2 = 4, anchor = BOT)
    position(TOP) down(sink) back(offset) scale(size) import(import);

function format2(n) = str(n < 10 ? "0" : "", n);