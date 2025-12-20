include<BOSL2/std.scad>

$fn = 72;
dia = 160;
h = 25;
diff() {
    cyl(d = dia, h = h, anchor = BOT);
    tag("remove") wedge([dia,dia,h-1], anchor = BOT);
}