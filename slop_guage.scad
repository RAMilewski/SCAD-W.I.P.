include <BOSL2/std.scad>

$fn = 72;

frame = [100,40,6];
plug = 10;
step = 0.05;



frame();


module frame() {
   diff()
     cuboid(frame, rounding = 2, teardrop = true )
         for (i = [-3:1:3]) {
            size = [plug + i * step, plug + i * step, frame.z +1];
            xpos = frame.x/7.5 * (i);
            back(frame.y/4) right(xpos) {
               tag("remove") cuboid(size, rounding = -1, edges = TOP);      
            }
            fwd(frame.y/4) right(xpos) {
               tag("remove") cyl(d = size.x, h = size.z, rounding2 = -1, circum = true);      
            }
            right(xpos) attach(TOP) color("blue") tag("remove")
               text3d(str(i * step), font="Arial Black", center = true, size = 3, anchor = TOP);
         }
}

module plug() {
   cuboid(plug, chamfer = 0.5, edges = "Z")
      attach(TOP) cyl(d = plug, h = plug, rounding2 = 1, anchor = BOT);
}

         