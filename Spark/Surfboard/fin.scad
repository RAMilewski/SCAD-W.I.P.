include<BOSL2/std.scad>
include<BOSL2/beziers.scad>
include<fin_250x230.scad>

*diff() {    
    back(98) right(44) zrot(8) {
    textured_tile(fin, [250,230], tex_depth = 7, tex_reps= [1,1], anchor = BOT);
    tag("remove") cuboid([250,230,2]);
    }
}



bezpath = flatten([
    bez_begin([0,0], 0, 100),
    bez_joint([185,0], 180, 140, 100,10),
    bez_tang([160,30], 130, 10),
    bez_tang([90,140], 130, 45),
    bez_tang([-40,200],180,60),
    bez_tang([-93,165], -90, 10),
    bez_tang([-35,120], -44, 30),
    bez_end([0,0], 80, 70),
]);

path = bezpath_curve(bezpath);
path1 = scale(.616 * (100.8/114), path);
path2 = scale(.99, path1);

module fin() {skin([path2,path1,path2], z=[0,2.5,5], slices = 2);}



module base() {
    diff() {
        cuboid([108.5,14.9,4.75], chamfer = -5, edges = RIGHT+BOT, anchor = BOT) {
            position(TOP) cuboid([105,5,5], chamfer = 2, edges = "Z", anchor = BOT);
            tag("remove") position(BOT) down(.01) left(50) back(2.5) xrot(90) fin();
        }
    }
}


module uni_fin() { 
    cuboid([108.5,14.9,4.75], chamfer = -5, edges = RIGHT+BOT, anchor = BOT)
        position(TOP) cuboid([105,5,5], chamfer = 2, edges = "Z", anchor = BOT)
            position(TOP) left(50) back(2.5) xrot(90) fin();
}

uni_fin();

//up(10) debug_bezier(bezpath);
/* */