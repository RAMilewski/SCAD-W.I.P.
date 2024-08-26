include<BOSL2/std.scad>

dia = 25;
wall = 2;
clip = [75,30,wall];
slot = [wall,wall+0.1,clip.y/2];

diff() {
    cuboid(clip, anchor = BOT, rounding = 10, edges = "Z"){
        position(BACK) tag("remove") cuboid([dia,clip.y,clip.z +0.1], anchor = BACK);
        position(FWD) xrot(90) tube(h = clip.y/2, id = dia, wall = wall, anchor = UP)  
            position(BACK) tag("remove") #cuboid(slot, anchor = BACK);
    }
}