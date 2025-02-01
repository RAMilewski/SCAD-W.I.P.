include<BOSL2/std.scad>
include<BOSL2/rounding.scad>


text1 = "";
font = "Phosphate:style=solid";  // ["Phosphate:style=solid","Righteous","Arial Black","Impact"]
font_size = 6.8;
label_fill = false;
label_depth = 0.2;
$fn = 72;

thickness = 2;

rounded_prism(rect([30,30]),h = thickness, joint_top = thickness/2, joint_bot = thickness/2, joint_sides = 5);

module label() {
    color("red") text3d(label_text, font = font, size = font_size, h = label_depth, center = true, atype = "ycenter");
}
