include <BOSL2/std.scad>

show = "cube"; //[cube,sphere,both]

if (show == "cube") recolor("red") cuboid(10);
if (show == "sphere") recolor("blue") spheroid(5);
    
echo(show);

if (show == "both") {left(20) cuboid(10); right(20) spheroid(5);}