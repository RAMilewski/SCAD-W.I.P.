include<BOSL2/std.scad>

$fn =72;
block = [40,18,5];
axle = [90, 7.75];
diff(){
    xcyl(d = axle.y, h = axle.x, rounding = 2){
        tag("remove") position(BOT) up(1) cuboid([90.1,8,5], anchor = TOP);
    }
}