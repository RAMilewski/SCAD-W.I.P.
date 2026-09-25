include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$export_name = "thread_test";

$fn = 144;

diff() {
    threaded_rod(d = 25.5, h = 10, pitch = 0.5, end_len1 = 8, lead_in_shape = "sqrt")
    tag("remove") cyl(d = 23, h = 11);
}