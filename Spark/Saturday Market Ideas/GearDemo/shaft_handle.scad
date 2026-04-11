include<BOSL2/std.scad>

$fn = 32;
path = turtle(["move",100,"arcright", 5, 30, "move", 10, "arcleft", 5, 30, "move", 10]);

diff(){
    path_sweep(rect([5,10]), path);
    ycyl(5,5);
    move(last(path)){
        ycyl(5,5);
        tag("remove") ycyl(5,2.2);
    }
}
