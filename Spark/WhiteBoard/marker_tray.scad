include<BOSL2/std.scad>

echo(BOSL_VERSION);

$fn = 64;

tray = [150,70,40];
depth = tray.z - 2;
pen = [17,20,depth];
spray = [35,38,depth];
eraser = [30,54,depth];
round = 5;


diff() {
    cuboid(tray, rounding = round, edges = "Z") {
        tag("remove") position(TOP+RIGHT) left(5) cyl(d1 = spray.x, d2 = spray.y, h = spray.z, rounding2 = -round/2, anchor = TOP+RIGHT);
        tag("remove") position(TOP) right(8) cuboid(eraser, rounding = -round/2, edges = TOP, anchor = TOP);
        grid_copies(n = [2,2], spacing = 1.8*pen.x)
            tag("remove") position(TOP+LEFT) right(pen.y+2) cyl(d1 = pen.y, d2 = pen.y, h = spray.z, rounding2 = -round, anchor = TOP+LEFT);
    }
}