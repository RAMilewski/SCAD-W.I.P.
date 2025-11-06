include <BOSL2/std.scad>
include <tex/Greek1_500x500.scad>
include <tex/BJ1_500x500.scad>

size = BJ1_size;
tilemult = [.1,.1];
tilesize = [size.x * tilemult.x, size.y * tilemult.y, 0.5];
echo (size*tilemult);
$fn = (72);

difference() {
        textured_tile(BJ1, tilesize, tex_reps = [1,1], tex_depth = 2)
            position(BOT) rot([0,180,180]) up(tilesize.z) right(0.25) textured_tile(Greek1, tilesize, tex_reps = [1,1], tex_depth = 2);    
        cutter();
};



module cutter() {
    difference() {
        cuboid([tilesize.x + 1, tilesize.y + 1, 5], anchor = CTR);
        cyl(h = 6, r = 24, anchor = CTR);
    }
}