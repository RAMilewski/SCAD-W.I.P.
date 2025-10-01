include <BOSL2/std.scad>

diff(){
    cuboid(25, anchor = BOT)
        tag("remove") position(FWD+BOT) cuboid(10, anchor = BOT)
            tag("remove") position(TOP) cuboid(10, anchor = BOT);
}