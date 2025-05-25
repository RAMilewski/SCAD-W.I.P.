include<BOSL2/std.scad>

rounded_prism(rect([75,35]), apply(right(5),rect([60,30])), h = 25, 
    joint_top = 3, joint_bot = 3, joint_sides = 3, anchor = BOT)
        align(TOP,RIGHT, inset = 2) onion(8, $fn = 8);