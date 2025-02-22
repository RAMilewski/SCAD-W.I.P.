include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
legD1 = 12;
legD2 = 6;
spec = [
    // legs
    fwd(8)*left(10), mb_cyl(d1=legD1, d2=legD2, h=20),
    fwd(8)*right(10), mb_cyl(d1=legD1, d2=legD2, h=20),
    back(8)*left(10), mb_cyl(d1=legD1, d2=legD2, h=20),
    back(8)*right(10), mb_cyl(d1=legD1, d2=legD2, h=20),
    up(20)*yrot(90), mb_capsule(d=25,h=40, influence=0.5),  // body
    right(20)*up(25)*yrot(-20), mb_capsule(r=7, h = 25, influence=0.1),  // head
    right(23)*up(10)*yrot(20), mb_cyl(d1 = 3, d2=6, h = 15, influence=0.2),    // trunk
    // ears
    right(20)*up(29)*fwd(11)*yrot(80)*scale([1.7,1,1]), mb_disk(r=5,h=5, influence=0.1),
    right(20)*up(29)*back(11)*yrot(80)*scale([1.7,1,1]), mb_disk(r=5,h=5, influence=0.1),
    // tusks
    right(25)*up(13)*fwd(5)*yrot(135), mb_capsule(r=1, h = 10, influence=0.1),
    right(25)*up(13)*back(5)*yrot(135), mb_capsule(r=1, h = 10, influence=0.1),
];
bb = [[-30,-20,-15], [30,20,40]];
vol = (-bb[0].x+bb[1].x) * (-bb[0].y+bb[1].y) * (-bb[0].z+bb[1].z);
echo(vol);
auto = log(vol/5000);
echo(auto);
//#translate(bb[0]) cube(bb[1]-bb[0]);
metaballs(spec, voxel_size=auto, bb,show_stats = true);
