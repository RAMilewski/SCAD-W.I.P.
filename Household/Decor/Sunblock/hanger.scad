include <BOSL2/std.scad>
$fn = 72;

width = 10;
thickness = 3;
notch = 6 + 2*thickness;
color_this("red") cuboid([47,thickness,width], anchor = BACK) {
    position(LEFT+BACK) cuboid([thickness,35,width], rounding = thickness, edges = "Z", except = RIGHT, anchor = RIGHT+BACK);
    position(RIGHT+BACK) cuboid([thickness,100,width], rounding = thickness, edges = RIGHT+BACK, anchor = LEFT+BACK)
        position(LEFT+FWD) cuboid([notch,notch,width], rounding = notch, edges = RIGHT+FWD, anchor = LEFT+BACK)
            position(RIGHT+BACK) #cuboid([thickness,thickness,width], anchor = FWD+RIGHT);
}
