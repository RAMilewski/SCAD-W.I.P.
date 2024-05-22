include<BOSL2/std.scad>

$fn = 72;

color1 = "yellow";
color2 = "goldenrod";

left(50)

recolor(color1) cuboid(30)
    recolor(color2) sphere(19);


right(50)

diff() 
    recolor(color1) cuboid(30)
        tag("remove") recolor(color2) sphere(19);


intersection() {
    recolor(color1) cuboid(30);
        recolor(color2) sphere(19);
}