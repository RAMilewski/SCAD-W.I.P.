include<BOSL2/std.scad>
$fn = 72;

//cuboid([90,7.5,2], rounding = 1, edges = ["Z",TOP]);

rounded_prism(rect([90,75]), apply(left(5), rect([80,75])),height=12,
                            joint_top=[1,1,1,4], joint_bot=0.5, joint_sides=1);

