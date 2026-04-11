include<BOSL2/std.scad>

$fn = 32;
path = turtle(["move",100,"arcright", 5, 30, "move", 10, "arcleft", 5, 30, "move", 10]);

diff(){
    path_sweep(rect([3,10]), path);
    ycyl(3,5);
    move(last(path)){
        ycyl(3,5);
        tag("remove") ycyl(3,2.01);
    }
}
