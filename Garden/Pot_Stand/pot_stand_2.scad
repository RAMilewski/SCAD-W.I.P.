include<BOSL2/std.scad>
$fn = 144;

style = "gargoyle"; // [gargoyle, onion, sphere, crystal, blank]

/* [Gargoyle Settngs] */
gargoyle = 14;   // [1:23]
size = 0.4;  //[.1:.05:1]
spin = 0;    //[-10:10]
offset = 5;  //[-5:10]
sink = 3;    //[0:15]

import = str("../Gargoyles/Gargoyle_",format2(gargoyle),"_MOD.stl");

echo (import);

rounded_prism(rect([125,50]), apply(left(12.5),rect([100,50])), h = 25, 
    joint_top = 5, joint_bot = 0, joint_sides = 5, anchor = BOT) {
        if (style == "gargoyle") { position([TOP]) down(sink) right(25 + offset) scale(size) zrot(90-spin) import(import); }
        if (style == "onion") { position([TOP]) right(35) down(5) onion(r = 15, ang = 50, anchor = BOT); }
        if (style == "crystal") { position([TOP]) right(35) down(5) zrot(180/8) onion(r = 15, ang = 50, $fn = 8, anchor = BOT); }
        if (style == "sphere") { position([TOP]) right(35) down(5) spheroid(r = 15, anchor = BOT); }        
    }

function format2(n) = str(n < 10 ? "0" : "", n);
