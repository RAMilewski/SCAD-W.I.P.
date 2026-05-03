include<BOSL2/std.scad>

$fn = 72;

depth = 45;
reach = 40;
width = 30;
wall  =  5;
theta =  2;


cuboid([wall,depth,width]){
    position(BACK+LEFT) rot(-theta) cuboid([reach,wall,width], rounding = wall/2, edges = "Z", except = FWD+LEFT,  anchor = LEFT);
    position(FWD+LEFT)  rot(theta)  cuboid([reach,wall,width], rounding = wall/2, edges = "Z", except = BACK+LEFT, anchor = LEFT);
}