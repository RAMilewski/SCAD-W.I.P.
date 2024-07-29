include<BOSL2/std.scad>

$fn = 72;
z = .75;
body = [35,28,z];
ear = [8,30];
slit = (ear.x + body.x)/2;

path = glued_circles(d = ear.x, spread = ear.y, tangent = 0);
diff(){
    cuboid(body, anchor = BOT){
        position([LEFT,RIGHT]) down(z/2) linear_sweep(path, h = z, spin = 90);
        tag("remove") right(slit/2) pie_slice(h = z , r =slit, ang = 4, center = true);
    }
}
    