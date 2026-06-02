include<BOSL2/std.scad>
include<base_cutout.scad>

base = [49.25,49.25];
basez = 4;
base3d = [base.x, base.y, basez];
top  = [51.75,51.75];
wall = [3,3];

rect1 = rect(base, chamfer = 7);
rect2 = rect(top,  chamfer = 7);
rect3 = rect(top-wall, chamfer = 7);
rect4 = rect(base-wall, chamfer = 7);

echo(base - [1.5,1.5]);

//back_half()
diff(){
    skin([rect1,rect1,rect2,rect3,rect4], z = [0,4,63.5,63.5,4], slices = 10){
    //cuboid(base3d, chamfer = 7, edges = "Z", anchor = BOT){
        tag("remove") position(BOT) base_cutout(groove = 2.25, anchor = BOT);
        tag("remove") position(BOT) cyl(h = 2, d1 = 28, d2 = 26 , anchor = BOT);

    }
}

/* */