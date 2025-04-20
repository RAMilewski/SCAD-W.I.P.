include<BOSL2/std.scad>

edge = 7.1;
wall = 1;
shell = (edge + wall * 2 + 0.5);
height = 20;
shape = rect([1.4,height]);
offset = 0.6;   // [0.1:0.1:1]

echo(shell-offset);

diff() {
    cuboid([shell,shell,height])
        tag("remove") cuboid([edge,edge,height+.1]);
        left(shell*offset) fwd(shell*offset) tag("remove") #cuboid([shell,shell,height+.1]);
}