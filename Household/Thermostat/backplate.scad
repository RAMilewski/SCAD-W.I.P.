include<BOSL2/std.scad>


body = [130,88];

plate = [130 * 1.477, 130, 0.6];
corner = 10;
cutout = [60,60,2];
arch = 30;

diff(){
    cuboid(plate, rounding = corner, edges = "Z", anchor = BOT);
    rect_tube(size = [plate.x,plate.y], wall = 3, h = 2, rounding = corner, anchor = BOT);
    tag("remove") #cuboid(cutout, rounding = corner, edges = "Z")
        position(BACK) back(5) tag("remove") cyl(d = 8, h = 2);
}