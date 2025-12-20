include<BOSL2/std.scad>

$fn = 72;
wall = 2;
frame = [80, 38.5, 19.5];
frame2 = [19.5, 38.5, 80];
echo(frame, frame2);
dim = frame.y * sqrt(2) + 2 * wall;
block = [dim, frame.y + 2 * wall, dim];


top_half() yrot(-45) sub_block();

module sub_block() {
    diff() {
        cuboid(block, rounding = 10, edges = "Y") {
            tag("remove") {
                align(TOP,  inside = true, shiftout = 0.1)  cuboid(frame);
                align(RIGHT,  inside = true, shiftout = 0.1) cuboid(frame2);
            }
        }
    }
}