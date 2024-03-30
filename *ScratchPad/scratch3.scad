include <BOSL2/std.scad>
$fn=72;
cyl(d = 20, h = 5, texture = "dots", tex_reps = [30,3], anchor = BOT)
   position(TOP) cyl(d = 10, h = 10, anchor = BOT);

           