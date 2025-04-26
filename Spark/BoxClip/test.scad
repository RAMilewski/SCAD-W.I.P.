include<BOSL2/std.scad>


difference() {
    import("reaction_wheel_cube_1.stl");
    #cyl(h = 10, d = 126, $fn = 72);
}