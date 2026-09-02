include <BOSL2/std.scad>

$export_name = "test";

union() {
//grid_copies( n = [2,2], spacing = 25) octohole();
move([-12.5,-12.5]) thread_hole();
}

module thread_hole() {
    import("STL_Lib/Small Thread Hole.stl");
}

module octohole() {
    import("STL_Lib/Large Octagon Hole.stl");
}