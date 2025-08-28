include<BOSL2/std.scad>

label_text = "Test";
font = "Phosphate:style=solid";  // ["Phosphate:style=solid","Righteous","Arial Black","Impact"]
font_size = 14;
label_fill = false;
label_depth = 0.2;
test = false;   
$fn = 72;

block2(); 

module block() {
    difference(){
        cuboid([40,20,5], rounding = 1, anchor = BOT);
        label();
    }
}

module block2() {
        cuboid([40,20,5], rounding = 1, anchor = BOT);
}

module label() {
    xscale(-1) text3d(label_text, font = font, size = font_size, h = label_depth, center = true, atype = "ycenter", anchor = BOT);
}