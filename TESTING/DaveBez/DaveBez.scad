include <BOSL2/std.scad>

depth = 2;
$fn=72;

path = turtle(["arcright",2,72.5, "move", 17.5,
    "arcleft", 2.35, 162.5, "move", 16.75, "arcright", 1, 90, 
    "move", 16.4, "arcleft", 2.35, 163.25, "move", 17,
    "arcright", 2, 72.5,],repeat = 4);

tool = circle(d = 3, spin=30, $fn = 3);  //a triangle actually

difference() {
    cyl(d = 75, h = 3, rounding = 1.5, anchor = TOP);
    down(depth) path_sweep(tool, path, closed = true, anchor = BOT);
}